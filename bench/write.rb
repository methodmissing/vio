$:.unshift "."
def relative(path)
  File.dirname(__FILE__) + path
end

require relative('/../ext/vio/vio')
require "benchmark"
require "logger"
require relative('/patched_logger')

PAYLOAD = ['a' * 100,
           'b' * 200,
           'c' * 300,
           'd' * 400,
           'e' * 500,
           'f' * 600,
           'g' * 700,
           'h' * 800,
           'i' * 900,
           'j' * 1000]

FILE = relative("/../test/fixtures/writable.txt")

logger = Logger.new(FILE)
logger.blank_slate

TESTS = 100_000
begin
  puts "* Bench log writes ..."
  Benchmark.bmbm do |results|
    results.report("IO.writev") { TESTS.times{ logger.addv(PAYLOAD) } }
    logger.blank_slate
    results.report("IO.write") { TESTS.times{ logger << PAYLOAD.join } }
  end
ensure
  logger.blank_slate
  logger.close
end