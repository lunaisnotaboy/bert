# frozen_string_literal: false

require 'mochilo'

module BERT
  class Decode
    attr_accessor :in

    include Types

    def self.impl
      'Ruby'
    end

    def self.decode(string)
      header = string.getbyte(0)

      case header
      when VERSION_4
        raise 'v4 stream cannot be decoded' unless BERT.supports?(:v4)

        Mochilo.unpack(string.byteslice(1, string.bytesize - 1))
      when VERSION_3
        raise 'v3 stream cannot be decoded' unless BERT.supports?(:v3)

        Mochilo.unpack_unsafe(string.byteslice(1, string.bytesize - 1))
      when MAGIC, VERSION_2
        io = StringIO.new(string)
        io.set_encoding('binary') if io.respond_to?(:set_encoding)
        io.getbyte
        new(io).read_any
      else
        fail('Bad Magic')
      end
    end

    def initialize(ins)
      @in = ins
      @peeked = ''
    end

    def read_any
      read_any_raw
    end

    def read_any_raw
      case peek_1
      when ATOM then read_atom
      when SMALL_INT then read_small_int
      when INT then read_int
      when SMALL_BIGNUM then read_small_bignum
      when LARGE_BIGNUM then read_large_bignum
      when FLOAT then read_float
      when SMALL_TUPLE then read_small_tuple
      when LARGE_TUPLE then read_large_tuple
      when NIL then read_nil
      when STRING then read_erl_string
      when LIST then read_list
      when BIN then read_bin
      when ENC_STRING then read_enc_string
      when UNICODE_STRING then read_unicode_string
      else
        fail("Unknown term tag: #{peek_1}")
      end
    end

    def read(length)
      if length < @peeked.length
        result = @peeked[0...length]
        @peeked = @peeked[length..]
        length = 0
      else
        result = @peeked
        @peeked = ''
        length -= result.length
      end

      result << @in.read(length) if length.positive?
      result
    end

    def peek(length)
      if length <= @peeked.length
        @peeked[0...length]
      else
        read_bytes = @in.read(length - @peeked.length)
        @peeked << read_bytes if read_bytes
        @peeked
      end
    end

    def peek_1
      peek(1).unpack1('C')
    end

    def peek_2
      peek(2).unpack1('n')
    end

    def read_1
      read(1).unpack1('C')
    end

    def read_2
      read(2).unpack1('n')
    end

    def read_4
      read(4).unpack1('N')
    end

    def read_string(length)
      read(length)
    end

    def read_atom
      fail('Invalid Type, not an atom') unless read_1 == ATOM

      length = read_2
      a = read_string(length)
      case a
      when ''
        Marshal.load("\004\b:\005") # Workaround for inability to do ''.to_sym
      else
        a.to_sym
      end
    end

    def read_small_int
      fail('Invalid Type, not a small int') unless read_1 == SMALL_INT

      read_1
    end

    def read_int
      fail('Invalid Type, not an int') unless read_1 == INT

      value = read_4
      negative = (value >> 31)[0] == 1
      value = (value - (1 << 32)) if negative
      value
    end

    def read_small_bignum
      fail('Invalid Type, not a small bignum') unless read_1 == SMALL_BIGNUM

      size = read_1
      sign = read_1
      bytes = read_string(size).unpack('C' * size)
      bytes.zip((0..bytes.length).to_a).inject(0) do |result, byte_index|
        byte, index = *byte_index
        value = (byte * (256**index))
        sign.zero? ? (result + value) : (result - value)
      end
    end

    def read_large_bignum
      fail('Invalid Type, not a large bignum') unless read_1 == LARGE_BIGNUM

      size = read_4
      sign = read_1
      bytes = read_string(size).unpack('C' * size)
      bytes.zip((0..bytes.length).to_a).inject(0) do |result, byte_index|
        byte, index = *byte_index
        value = (byte * (256**index))
        sign.zero? ? (result + value) : (result - value)
      end
    end

    def read_float
      fail('Invalid Type, not a float') unless read_1 == FLOAT

      string_value = read_string(31)
      string_value.to_f
    end

    def read_small_tuple
      fail('Invalid Type, not a small tuple') unless read_1 == SMALL_TUPLE

      read_tuple(read_1)
    end

    def read_large_tuple
      fail('Invalid Type, not a small tuple') unless read_1 == LARGE_TUPLE

      read_tuple(read_4)
    end

    def read_tuple(arity)
      if arity.positive?
        tag = read_any_raw
        if tag == :bert
          read_complex_type(arity)
        else
          tuple = Tuple.new(arity)
          tuple[0] = tag
          (arity - 1).times { |i| tuple[i + 1] = read_any_raw }
          tuple
        end
      else
        Tuple.new
      end
    end

    def read_complex_type(_arity)
      case read_any_raw
      when :nil
        nil
      when :true
        true
      when :false
        false
      when :time
        Time.at((read_any_raw * 1_000_000) + read_any_raw, read_any_raw)
      when :regex
        source = read_any_raw
        opts = read_any_raw
        options = 0
        options |= Regexp::EXTENDED if opts.include?(:extended)
        options |= Regexp::IGNORECASE if opts.include?(:caseless)
        options |= Regexp::MULTILINE if opts.include?(:multiline)
        Regexp.new(source, options)
      when :dict
        read_dict
      end
    end

    def read_dict
      type = read_1
      fail('Invalid dict spec, not an erlang list') unless [LIST, NIL].include?(type)

      length = if type == LIST
                 read_4
               else
                 0
               end
      hash = {}
      length.times do |_i|
        pair = read_any_raw
        hash[pair[0]] = pair[1]
      end
      read_1 if type == LIST
      hash
    end

    def read_nil
      fail('Invalid Type, not a nil list') unless read_1 == NIL

      []
    end

    def read_unicode_string
      fail('Invalid Type, not a unicode string') unless read_1 == UNICODE_STRING

      length = read_4
      str = read_string(length)
      str.force_encoding 'UTF-8'
      str
    end

    def read_erl_string
      fail('Invalid Type, not an erlang string') unless read_1 == STRING

      length = read_2
      read_string(length).unpack('C' * length)
    end

    def read_list
      fail('Invalid Type, not an erlang list') unless read_1 == LIST

      length = read_4
      list = (0...length).map { |_i| read_any_raw }
      read_1
      list
    end

    def read_bin
      fail('Invalid Type, not an erlang binary') unless read_1 == BIN

      length = read_4
      read_string(length)
    end

    def fail(str)
      raise str
    end

    private

    def read_enc_string
      fail('Invalid Type, not an erlang binary') unless read_1 == ENC_STRING

      length = read_4
      x = read_string(length)

      fail('Invalid Type, not an erlang binary') unless read_1 == BIN

      length = read_4
      x.force_encoding read_string(length)
      x
    end
  end
end
