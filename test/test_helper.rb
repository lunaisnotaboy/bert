# frozen_string_literal: true

require 'rubygems'

require 'test/unit'

require 'shoulda'
require 'shoulda/context'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

load 'bert.rb'

if ENV.key?('BERT_TEST_IMPL') && ENV['BERT_TEST_IMPL'] != BERT::Decode.impl
  raise "Incorrect implementation loaded for value of BERT_TEST_IMPL environment variable! Wanted #{ENV['BERT_TEST_IMPL']}, but loaded #{BERT::Decode.impl}."
end

puts "Using #{BERT::Decode.impl} implementation."
