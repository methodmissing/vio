$:.unshift "."
def relative(path)
  File.dirname(__FILE__) + path
end

require relative('/../ext/vio/vio')
require "benchmark"

FILE = relative("/../test/fixtures/fix.txt")
SEP = "\x01".freeze

source = File.open(FILE)
TESTS = 100_000
begin
  puts "* Bench reads ..."
  Benchmark.bmbm do |results|
    results.report("IO.readv") { TESTS.times{ source.readv(9, 5, 5, 6, 8, 26, 8) } }
    results.report("IO.read") { TESTS.times{ source.read.split(SEP) } }
  end
ensure
  source.close
end