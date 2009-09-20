Gem::Specification.new do |s|
  s.name     = "vio"
  s.version  = "0.2.0"
  s.date     = "2009-09-19"
  s.summary  = "Vectored I/O extension for Ruby"
  s.email    = "lourens@methodmissing.com"
  s.homepage = "http://github.com/methodmissing/vio"
  s.description = "Vectored I/O extension for Ruby MRI (1.8.{6,7} and 1.9.2)"
  s.has_rdoc = true
  s.authors  = ["Lourens Naudé (methodmissing)"]
  s.platform = Gem::Platform::RUBY
  s.files    = %w[
    README
    Rakefile
    ext/vio/extconf.rb
    ext/vio/vio.c
    vio.gemspec
  ] + Dir.glob('test/*')
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
  s.extensions << "ext/vio/extconf.rb"
end