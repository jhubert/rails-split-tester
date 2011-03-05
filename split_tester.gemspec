# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "split_tester/version"

Gem::Specification.new do |s|
  s.name        = "split_tester"
  s.version     = SplitTester::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeremy Hubert"]
  s.email       = ["jhubert@gmail.com"]
  s.homepage    = "http://github.com/jhubert/rails-split-tester"
  s.summary     = %q{Provides A/B split testing functionality for Rails}
  s.description = %q{Split Tester provides support for A/B Split testing your pages with integration into Google Analytics.}

  s.rubyforge_project = "rails_split_tester"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency('rails',  '>=3.0.0')
end