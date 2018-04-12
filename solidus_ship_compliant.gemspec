# encoding: UTF-8
$:.push File.expand_path('../lib', __FILE__)
require 'solidus_ship_compliant/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_ship_compliant'
  s.version     = SolidusShipCompliant::VERSION
  s.author      = 'Jonathan Tapia'
  s.email       = 'jonathan.tapia@magmalabs.io'
  s.homepage    = 'http://github.com/jtapia/solidus_ship_compliant'
  s.summary     = 'Solidus Engine for Ship compliant tax calculation service'
  s.description = 'Solidus Engine for Ship compliant tax calculation service'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  solidus_version = ['>= 1.2', '< 3']
  s.add_dependency 'solidus_core', solidus_version
  s.add_dependency 'solidus_backend', solidus_version
  s.add_dependency 'solidus_support'
  s.add_dependency 'deface', '~> 1.0'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'capybara', '~> 2.17'
  s.add_development_dependency 'selenium-webdriver', '~> 3.9'
  s.add_development_dependency 'database_cleaner', '~> 1.3'
  s.add_development_dependency 'factory_bot', '~> 4.5'
  s.add_development_dependency 'ffaker', '>= 1.25.0'
  s.add_development_dependency 'poltergeist', '~> 1.17'
  s.add_development_dependency 'pry-rails', '>= 0.3.0'
  s.add_development_dependency 'rubocop', '>= 0.24.1'
  s.add_development_dependency 'rspec-rails', '~> 3.1'
  s.add_development_dependency 'simplecov', '~> 0.9'
end
