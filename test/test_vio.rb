$:.unshift "."
require File.dirname(__FILE__) + '/helper'

class TestVectoredIO < Test::Unit::TestCase
  
  def test_defines_readv_and_writev
    io = File.open(fixture('db.txt'))
    assert io.respond_to? :readv
    assert io.respond_to? :writev
    io.close
  end
  
end