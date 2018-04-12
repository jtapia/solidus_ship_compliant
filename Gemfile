source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem 'solidus', github: 'solidusio/solidus', branch: branch
gem 'solidus_auth_devise', github: 'solidusio/solidus_auth_devise'

if branch == 'master' || branch >= 'v2.0'
  gem 'rails-controller-testing', group: :test
else
  gem 'rails_test_params_backport', group: :test
end

gem 'ship_compliant', github: 'ShipCompliant/ship_compliant-ruby'

gem 'pg', '~> 0.21'
gem 'sqlite3'
gem 'mysql2', '~> 0.4.10'
gem 'pry'
gem 'pry-rails'

gemspec
