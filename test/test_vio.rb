$:.unshift "."
require File.dirname(__FILE__) + '/helper'

class TestVectoredIO < Test::Unit::TestCase
  CONTENT = [ "8=FIX.4.4", "\x019=45", "\x0135=0", "\x0149=TW", "\x0156=ISLD",
"\x0134=3\x0152=20000426-12:05:06", "\x0110=220\x01" ]
  LENGTHS = [9, 5, 5, 6, 8, 26, 8]
  
  def test_readv_arguments
    io = File.open(fixture('fix.txt'))
    assert_raises TypeError do
      io.readv(nil)
    end
    assert_raises IOError do    
      io.readv []
    end
    io.close
  end
  
  def test_readv
    io = File.open(fixture('fix.txt'))
    expected = CONTENT
    assert_equal expected, io.readv(LENGTHS)
    io.close
  end  
   
  def test_writev_arguments
    io = File.open(fixture('writable.txt'), 'w')
    assert_raises TypeError do
      io.writev(nil)
    end
    assert_raises IOError do
      io.writev []
    end
    io.close
  end 

  def test_writev
    io = File.open(fixture('writable.txt'), 'w')
    expected = LENGTHS
    assert_equal expected, io.writev(CONTENT.dup)
    io.truncate(0)
    io.close
  end 
end