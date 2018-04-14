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

  solidus_version = ['>= 2.0', '< 3']
  s.add_dependency 'solidus_core', solidus_version
  s.add_dependency 'solidus_support'
  s.add_dependency 'deface', '~> 1.0'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'simplecov'
end
