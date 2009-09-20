require 'fileutils'
require 'test/unit'
require 'vio'

FIXTURES = File.dirname(__FILE__) + "/fixtures"

def fixtures(*files)
  files.map{|f| File.join(FIXTURES,f) }
end

def fixture(file)
  file =~ /\// ? file : fixtures(*file).first
end