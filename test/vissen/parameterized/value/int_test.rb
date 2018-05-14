# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Value::Int do
  subject   { Vissen::Parameterized::Value::Int }
  let(:int) { subject.new }

  describe '.new' do
    it 'defaults to 0' do
      assert_same 0, int.value
    end

    it 'coerces arguemnts to an integer' do
      int = subject.new 42.0
      assert_same 42, int.value
    end

    it 'raises a TypeError for unknown objects' do
      assert_raises(TypeError) { subject.new Object.new }
    end
  end
end
