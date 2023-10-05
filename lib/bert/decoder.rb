# frozen_string_literal: true

module BERT
  class Decoder
    # Decode a BERT into a Ruby object
    #
    # @param [String] bert A BERT String
    # @return [Object] A decoded Object
    def self.decode(bert)
      Decode.decode(bert)
    end
  end
end
