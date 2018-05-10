# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
SimpleCov.start 'test_frameworks'

require 'vissen/parameterized'

module TestHelper
  class ValueMock
    include Vissen::Parameterized::Value

    DEFAULT = rand
  end
end

require 'minitest/autorun'
