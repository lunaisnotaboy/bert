# frozen_string_literal: true

require 'mkmf'

append_cflags('-fvisibility=hidden -Wall')

create_makefile('bert/c/decode')
