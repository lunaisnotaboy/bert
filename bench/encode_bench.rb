# frozen_string_literal: true

require 'benchmark'
require 'bert'
require 'json'
require 'yajl'

ITER = 1_000

complex = [42, { foo: 'bac' * 100 }, t[(1..100).to_a]] * 10
large = ['abc' * 1000] * 100
small = t[:ok, :answers, [42] * 42]
tiny = t[:ok, :awesome]

Benchmark.bm(13) do |bench|
  bench.report('BERT complex') { ITER.times { BERT.encode(complex) } }
  bench.report('BERT large') { ITER.times { BERT.encode(large) } }
  bench.report('BERT small') { ITER.times { BERT.encode(small) } }
  bench.report('BERT tiny') { ITER.times { BERT.encode(tiny) } }

  puts

  bench.report('JSON complex') { ITER.times { JSON.dump(complex) } }
  bench.report('JSON large') { ITER.times { JSON.dump(large) } }
  bench.report('JSON small') { ITER.times { JSON.dump(small) } }
  bench.report('JSON tiny') { ITER.times { JSON.dump(tiny) } }

  puts

  bench.report('YAJL complex') { ITER.times { Yajl::Encoder.encode(complex) } }
  bench.report('YAJL large') { ITER.times { Yajl::Encoder.encode(large) } }
  bench.report('YAJL small') { ITER.times { Yajl::Encoder.encode(small) } }
  bench.report('YAJL tiny') { ITER.times { Yajl::Encoder.encode(tiny) } }

  puts

  bench.report('Ruby complex') { ITER.times { Marshal.dump(complex) } }
  bench.report('Ruby large') { ITER.times { Marshal.dump(large) } }
  bench.report('Ruby small') { ITER.times { Marshal.dump(small) } }
  bench.report('Ruby tiny') { ITER.times { Marshal.dump(tiny) } }
end
