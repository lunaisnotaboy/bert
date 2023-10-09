# frozen_string_literal: true

require 'benchmark'
require 'json'
require 'yajl'

ITER = 1_000

def setup
  complex = [42, { foo: 'bac' * 100 }, t[(1..100).to_a]] * 10
  large = ['abc' * 1000] * 100
  small = t[:ok, :answers, [42] * 42]
  tiny = t[:ok, :awesome]

  $complex_encoded_bert = BERT.encode(complex)
  $large_encoded_bert = BERT.encode(large)
  $small_encoded_bert = BERT.encode(small)
  $tiny_encoded_bert = BERT.encode(tiny)

  $complex_encoded_json = JSON.dump(complex)
  $large_encoded_json = JSON.dump(large)
  $small_encoded_json = JSON.dump(small)
  $tiny_encoded_json = JSON.dump(tiny)

  $complex_encoded_ruby = Marshal.dump(complex)
  $large_encoded_ruby = Marshal.dump(large)
  $small_encoded_ruby = Marshal.dump(small)
  $tiny_encoded_ruby = Marshal.dump(tiny)

  $complex_encoded_yajl = Yajl::Encoder.encode(complex)
  $large_encoded_yajl = Yajl::Encoder.encode(large)
  $small_encoded_yajl = Yajl::Encoder.encode(small)
  $tiny_encoded_yajl = Yajl::Encoder.encode(tiny)
end

Benchmark.bm(13) do |bench|
  pid = fork do
    ENV['BERT_TEST_IMPL'] = 'C'

    require 'bert'

    raise 'Could not load C extension' unless BERT::Decode.impl == 'C'

    setup

    bench.report('BERT (C) complex') { ITER.times { BERT.decode($complex_encoded_bert) } }
    bench.report('BERT (C) large') { ITER.times { BERT.decode($large_encoded_bert) } }
    bench.report('BERT (C) small') { ITER.times { BERT.decode($small_encoded_bert) } }
    bench.report('BERT (C) tiny') { ITER.times { BERT.decode($tiny_encoded_bert) } }

    puts
  end

  Process.waitpid(pid)

  pid = fork do
    ENV['BERT_TEST_IMPL'] = 'Ruby'

    require 'bert'

    raise 'Not using Ruby decoder' unless BERT::Decode.impl == 'Ruby'

    setup

    bench.report('BERT (Ruby) complex') { ITER.times { BERT.decode($complex_encoded_bert) } }
    bench.report('BERT (Ruby) large') { ITER.times { BERT.decode($large_encoded_bert) } }
    bench.report('BERT (Ruby) small') { ITER.times { BERT.decode($small_encoded_bert) } }
    bench.report('BERT (Ruby) tiny') { ITER.times { BERT.decode($tiny_encoded_bert) } }

    puts
  end

  Process.waitpid(pid)

  require 'bert'

  setup

  bench.report('JSON complex') { ITER.times { JSON.load($complex_encoded_json) } }
  bench.report('JSON large') { ITER.times { JSON.load($large_encoded_json) } }
  bench.report('JSON small') { ITER.times { JSON.load($small_encoded_json) } }
  bench.report('JSON tiny') { ITER.times { JSON.load($tiny_encoded_json) } }

  puts

  bench.report('Ruby complex') { ITER.times { Marshal.load($complex_encoded_ruby) } }
  bench.report('Ruby large') { ITER.times { Marshal.load($large_encoded_ruby) } }
  bench.report('Ruby small') { ITER.times { Marshal.load($small_encoded_ruby) } }
  bench.report('Ruby tiny') { ITER.times { Marshal.load($tiny_encoded_ruby) } }

  puts

  bench.report('YAJL complex') { ITER.times { Yajl::Parser.parse($complex_encoded_yajl) } }
  bench.report('YAJL large') { ITER.times { Yajl::Parser.parse($large_encoded_yajl) } }
  bench.report('YAJL small') { ITER.times { Yajl::Parser.parse($small_encoded_yajl) } }
  bench.report('YAJL tiny') { ITER.times { Yajl::Parser.parse($tiny_encoded_yajl) } }
end
