# 🥀 Vissen Parameterized

[![Gem Version](https://badge.fury.io/rb/vissen-parameterized.svg)](https://badge.fury.io/rb/vissen-parameterized)
[![Build Status](https://travis-ci.org/midi-visualizer/vissen-parameterized.svg?branch=master)](https://travis-ci.org/midi-visualizer/vissen-parameterized)
[![Inline docs](http://inch-ci.org/github/midi-visualizer/vissen-parameterized.svg?branch=master)](http://inch-ci.org/github/midi-visualizer/vissen-parameterized)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/vissen-parameterized/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vissen-parameterized'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vissen-parameterized

## Usage

```ruby
class Doubler
  include Parameterized
  extend  Parameterized::DSL
  
  param input: Value::Real
  output Value::Real
  
  def call(params)
    params.input * 2
  end
end

external_value = Value::Real.new 21

doubler = Doubler.new
doubler.bind :input, external_value

# A tainted check is needed before reading the value
doubler.tainted? # => true
doubler.value # => 42.0

# Make sure untaint! is called before any value is changed
doubler.untaint!

external_value.set 4.5

# Before the taint check the old value is returned
doubler.value # => 42.0
doubler.tainted? # => true
doubler.value # => 9.0
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/midi-visualizer/vissen-parameterized.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
