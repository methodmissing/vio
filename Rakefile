#!/usr/bin/env rake
require 'rake/testtask'
require 'rake/clean'
$:.unshift(File.expand_path('lib'))
VIO_ROOT = 'ext/vio'

desc 'Default: test'
task :default => :test

desc 'Run VIO tests.'
Rake::TestTask.new(:test) do |t|
  t.libs = [VIO_ROOT]
  t.pattern = 'test/test_*.rb'
  t.verbose = true
end
task :test => :build

namespace :build do
  file "#{VIO_ROOT}/vio.c"
  file "#{VIO_ROOT}/extconf.rb"
  file "#{VIO_ROOT}/Makefile" => %W(#{VIO_ROOT}/vio.c #{VIO_ROOT}/extconf.rb) do
    Dir.chdir(VIO_ROOT) do
      ruby 'extconf.rb'
    end
  end

  desc "generate makefile"
  task :makefile => %W(#{VIO_ROOT}/Makefile #{VIO_ROOT}/vio.c)

  dlext = Config::CONFIG['DLEXT']
  file "#{VIO_ROOT}/vio.#{dlext}" => %W(#{VIO_ROOT}/Makefile #{VIO_ROOT}/vio.c) do
    Dir.chdir(VIO_ROOT) do
      sh 'make' # TODO - is there a config for which make somewhere?
    end
  end

  desc "compile vio extension"
  task :compile => "#{VIO_ROOT}/vio.#{dlext}"

  task :clean do
    Dir.chdir(VIO_ROOT) do
      sh 'make clean'
    end if File.exists?("#{VIO_ROOT}/Makefile")
  end

  CLEAN.include("#{VIO_ROOT}/Makefile")
  CLEAN.include("#{VIO_ROOT}/vio.#{dlext}")
end

task :clean => %w(build:clean)

desc "compile"
task :build => %w(build:compile)

task :install do |t|
  Dir.chdir(VIO_ROOT) do
    sh 'sudo make install'
  end
end

desc "clean build install"
task :setup => %w(clean build install)

namespace :bench do |t|
  desc "bench reads"
  task :read do
    ruby "bench/read.rb"
  end

  desc "bench writes"
  task :write do
    ruby "bench/write.rb"
  end
end
task :bench => :build