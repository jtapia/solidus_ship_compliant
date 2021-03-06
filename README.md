SolidusShipCompliant
====================

[![Build Status](https://travis-ci.org/jtapia/solidus_ship_compliant.svg?branch=master)](https://travis-ci.org/jtapia/solidus_ship_compliant)

Add Solidus ability to calculate rate taxes based on Ship Compliant third party

Requirements
------------

- Define taxonomies and taxons related # [ Brands, Categories ]
- Define the necessary `product_properties` # [ bottle_size, default_case, default_wholesale_case_price, percent_alcohol, varietal, vintage, volume_amount, volume_unit ]
- Create relation between `products` - `taxons` and `product_properties`

Installation
------------

Add solidus_ship_compliant to your Gemfile:

```ruby
gem 'solidus_ship_compliant'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g solidus_ship_compliant:install
```

Testing
-------

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs, and [Rubocop](https://github.com/bbatsov/rubocop) static code analysis. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle
bundle exec rake
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'solidus_ship_compliant/factories'
```

Copyright (c) 2018 [name of extension creator], released under the New BSD License
