Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'split_tester'
  s.version     = '0.4'
  s.summary     = 'Provides A/B split testing functionality for Rails'
  s.description = 'Split Tester provides support for A/B Split testing your pages with integration into Google Analytics.'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.author            = 'Jeremy Hubert'
  s.email             = 'jhubert@gmail.com'
  s.homepage          = 'http://www.jeremyhubert.com'

  s.add_dependency('rails',  '>=3.0.0')
end