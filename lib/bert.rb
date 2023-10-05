# frozen_string_literal: true

require 'stringio'

require 'bert/bert'
require 'bert/types'

case ENV['BERT_TEST_IMPL']
when 'C'
  require 'bert/c/decode'
when 'Ruby'
  require 'bert/decode'
else
  begin
    # Try to load the C extension
    require 'bert/c/decode'
  rescue LoadError
    # Fall back on the pure Ruby version
    require 'bert/decode'
  end
end

require 'bert/encode'
require 'bert/encoder'

require 'bert/decoder'

# TODO: figure out if the global method needs to be, well, global
def t
  BERT::Tuple
end
