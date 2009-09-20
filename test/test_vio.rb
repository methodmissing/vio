$:.unshift "."
require File.dirname(__FILE__) + '/helper'

class TestVectoredIO < Test::Unit::TestCase
  
  def test_readv_arguments
    io = File.open(fixture('fix.txt'))
    assert_raises TypeError do
      io.readv(nil)
    end
    assert_raises IOError do    
      io.readv []
    end
    io.readv [1]
    io.close
  end
  
  def test_readv
    io = File.open(fixture('fix.txt'))
    expected = [ "8=FIX.4.4", "\x019=45", "\x0135=0", "\x0149=TW", "\x0156=ISLD",
"\x0134=3\x0152=20000426-12:05:06", "\x0110=220" ]
    assert_equal expected, io.readv([9, 5, 5, 6, 8, 26, 7])
    io.close
  end  
   
  def test_writev_arguments
    io = File.open(fixture('writable.txt'), 'w')
    assert_raises TypeError do
      io.writev(nil)
    end
    io.writev []
    io.close
  end  
end