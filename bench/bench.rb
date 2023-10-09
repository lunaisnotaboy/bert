# frozen_string_literal: true

require 'benchmark'
require 'bert'
require 'json'
require 'yajl'

ITER = 1_000
LONG_ITER = 100

complex = [42, { foo: 'bac' * 100 }, t[(1..100).to_a]] * 10
large = ['abc' * 1000] * 100
long_array = { a: ['a', :a, Time.now, /a/] * 1000 }
small = t[:ok, :answers, [42] * 42]
tiny = t[:ok, :awesome]

Benchmark.bm(30) do |bench|
  %i[v1 v2 v3 v4].each do |v|
    unless BERT.supports?(v)
      puts "SKIP #{v} (unsupported)"
      puts

      next
    end

    BERT::Encode.version = v

    bench.report("BERT #{v} complex") { ITER.times { BERT.decode(BERT.encode(complex)) } }
    bench.report("BERT #{v} large") { ITER.times { BERT.decode(BERT.encode(large)) } }
    bench.report("BERT #{v} long array") { LONG_ITER.times { BERT.decode(BERT.encode(long_array)) } }
    bench.report("BERT #{v} small") { ITER.times { BERT.decode(BERT.encode(small)) } }
    bench.report("BERT #{v} tiny") { ITER.times { BERT.decode(BERT.encode(tiny)) } }

    puts
  end

  bench.report('JSON complex') { ITER.times { JSON.load(JSON.dump(complex)) } }
  bench.report('JSON large') { ITER.times { JSON.load(JSON.dump(large)) } }
  bench.report('JSON long array') { LONG_ITER.times { JSON.load(JSON.dump(long_array)) } }
  bench.report('JSON small') { ITER.times { JSON.load(JSON.dump(small)) } }
  bench.report('JSON tiny') { ITER.times { JSON.load(JSON.dump(tiny)) } }

  puts

  bench.report('Ruby complex') { ITER.times { Marshal.load(Marshal.dump(complex)) } }
  bench.report('Ruby large') { ITER.times { Marshal.load(Marshal.dump(large)) } }
  bench.report('Ruby long array') { LONG_ITER.times { Marshal.load(Marshal.dump(long_array)) } }
  bench.report('Ruby small') { ITER.times { Marshal.load(Marshal.dump(small)) } }
  bench.report('Ruby tiny') { ITER.times { Marshal.load(Marshal.dump(tiny)) } }

  puts

  bench.report('YAJL complex') { ITER.times { Yajl::Parser.parse(Yajl::Encoder.encode(complex)) } }
  bench.report('YAJL large') { ITER.times { Yajl::Parser.parse(Yajl::Encoder.encode(large)) } }
  bench.report('YAJL long array') { LONG_ITER.times { Yajl::Parser.parse(Yajl::Encoder.encode(long_array)) } }
  bench.report('YAJL small') { ITER.times { Yajl::Parser.parse(Yajl::Encoder.encode(small)) } }
  bench.report('YAJL tiny') { ITER.times { Yajl::Parser.parse(Yajl::Encoder.encode(tiny)) } }
end
