# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Parameter do
  subject { Vissen::Parameterized::Parameter }

  let(:value_klass) { Vissen::Parameterized::Value::Real }
  let(:parameter)   { subject.new value_klass }
  let(:target)      { value_klass.new 42 }

  describe '.new' do
    it 'creates a constant parameter' do
      assert parameter.constant?
    end

    it 'uses the default value of the given type' do
      assert_equal value_klass::DEFAULT, parameter.value
    end
  end

  describe 'constant parameter' do
    describe '#clear!' do
      it 'resets the constant value' do
        parameter.set 42
        parameter.clear!
        assert_equal value_klass::DEFAULT, parameter.value
      end
    end

    describe '#set' do
      it 'stores a new constant value' do
        parameter.set 42
        assert_equal 42.0, parameter.value
      end
    end

    describe '#target' do
      it 'raises a RuntimeError' do
        assert_raises(RuntimeError) { parameter.target }
      end
    end
  end

  describe '#bind' do
    it 'returns self' do
      assert_equal parameter, parameter.bind(target)
    end
  end

  describe 'bound parameter' do
    before { parameter.bind target }

    describe '#constant?' do
      it 'returns false' do
        refute parameter.constant?
      end
    end

    describe '#clear!' do
      before { parameter.clear! }

      it 'makes the parameter constant' do
        assert parameter.constant?
      end

      it 'sets the value to the default' do
        assert_equal value_klass::DEFAULT, parameter.value
      end
    end

    describe '#target' do
      it 'returns the target' do
        assert_same target, parameter.target
      end
    end

    describe '#set' do
      it 'stores a new constant value' do
        parameter.set 4.2
        assert parameter.constant?
        assert_equal 4.2, parameter.value
      end
    end

    describe '#value' do
      it 'returns the value of the target' do
        assert_equal target.value, parameter.value
      end
    end
  end
end
