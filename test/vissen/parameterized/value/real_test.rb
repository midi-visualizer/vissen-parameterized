# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Value::Real do
  subject    { Vissen::Parameterized::Value::Real }
  let(:real) { subject.new }

  describe '.new' do
    it 'defaults to 0.0' do
      assert_equal 0.0, real.value
    end

    it 'coerces arguemnts to a float' do
      real = subject.new 42
      assert_same 42.0, real.value
    end

    it 'raises a TypeError for unknown objects' do
      assert_raises(TypeError) { subject.new Object.new }
    end
  end
end
