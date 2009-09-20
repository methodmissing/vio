$:.unshift "."
require File.dirname(__FILE__) + '/../ext/vio/vio'
require "benchmark"

FILE = File.dirname(__FILE__) + "/../test/fixtures/fix.txt"
LENGTHS = [9, 5, 5, 6, 8, 26, 8]
SEP = "\x01".freeze

source = File.open(FILE)
TESTS = 10_000
begin
  puts "* Bench reads ..."
  Benchmark.bmbm do |results|
    results.report("IO.readv") { TESTS.times{ source.readv(LENGTHS) } }  
    results.report("IO.read") { TESTS.times{ source.read.split(SEP) } }  
  end
ensure
  source.close
end