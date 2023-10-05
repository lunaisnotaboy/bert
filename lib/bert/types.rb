# frozen_string_literal: true

module BERT
  module Types
    ATOM = 100
    BIN = 109
    ENC_STRING = 112
    FLOAT = 99
    FUN = 117
    INT = 98
    LARGE_BIGNUM = 111
    LARGE_TUPLE = 105
    LIST = 108
    MAGIC = 131
    MAX_INT = (1 << 27) - 1
    MIN_INT = -(1 << 27)
    NIL = 106
    SMALL_BIGNUM = 110
    SMALL_INT = 97
    SMALL_TUPLE = 104
    STRING = 107
    UNICODE_STRING = 113
    VERSION_2 = 132
    VERSION_3 = 133
    VERSION_4 = 134
  end
end
