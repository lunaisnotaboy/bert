# frozen_string_literal: false

module BERT
  class Encoder
    # Convert a simple-form Ruby object to a complex-form Ruby object
    #
    # @param [Object] ruby The Ruby object to convert
    # @return [Object] The converted Ruby object
    def self.convert(item)
      return item if Encode.version == :v3 || Encode.version == :v4

      case item
      when Hash
        pairs = []
        item.each_pair { |k, v| pairs << t[convert(k), convert(v)] }
        t[:bert, :dict, pairs]
      when Tuple
        Tuple.new(item.map { |x| convert(x) })
      when Array
        item.map { |x| convert(x) }
      when nil
        t[:bert, :nil]
      when TrueClass
        t[:bert, :true]
      when FalseClass
        t[:bert, :false]
      when Time
        t[:bert, :time, item.to_i / 1_000_000, item.to_i % 1_000_000, item.usec]
      when Regexp
        options = []
        options << :caseless if (item.options & Regexp::IGNORECASE).positive?
        options << :extended if (item.options & Regexp::EXTENDED).positive?
        options << :multiline if (item.options & Regexp::MULTILINE).positive?
        t[:bert, :regex, item.source, options]
      else
        item
      end
    end

    # Encode a Ruby object into a BERT object
    #
    # @param [Object] ruby The Ruby object to encode
    # @return [Object] An encoded BERT object
    def self.encode(ruby)
      complex_ruby = convert(ruby)

      Encode.encode(complex_ruby)
    end

    def self.encode_to_buffer(ruby)
      complex_ruby = convert(ruby)

      Encode.encode_to_buffer(complex_ruby)
    end
  end
end
