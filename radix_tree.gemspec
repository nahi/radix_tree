require 'rubygems'
Gem::Specification.new { |s|
  s.name = "radix_tree"
  s.version = "1.0.0.dev.2"
  s.date = "2012-01-05"
  s.author = "Hiroshi Nakamura"
  s.email = "nahi@ruby-lang.org"
  s.homepage = "http://github.com/nahi/radix_tree"
  s.platform = Gem::Platform::RUBY
  s.summary = "Naive implementation of Radix Tree for Ruby"
  s.files = Dir.glob('{lib,test}/**/*') + ['README']
  s.require_path = "lib"
}
