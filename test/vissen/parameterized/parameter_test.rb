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
      assert_same value_klass::DEFAULT, parameter.value
    end

    it 'accepts an initial value' do
      parameter = subject.new value_klass, 1
      assert_same 1.0, parameter.value
    end
  end

  describe 'constant parameter' do
    describe '#clear!' do
      it 'resets the constant value' do
        parameter.set 42
        parameter.clear!
        assert_same value_klass::DEFAULT, parameter.value
      end

      it 'resets to the initial value if given one' do
        parameter = subject.new value_klass, 1
        parameter.set 42
        parameter.clear!
        assert_same 1.0, parameter.value
      end
    end

    describe '#set' do
      it 'stores a new constant value' do
        parameter.set 42
        assert_same 42.0, parameter.value
      end
    end

    describe '#target' do
      it 'raises a RuntimeError' do
        assert_raises(RuntimeError) { parameter.target }
      end
    end

    describe '#unbind' do
      it 'raises a runtime error' do
        assert_raises(RuntimeError) { parameter.unbind }
      end
    end

    describe '#to_s' do
      it 'returns the string value' do
        assert_equal '(0.0*)', parameter.to_s
      end
    end

    describe '#inspect' do
      it 'returns a string representation of the parameter' do
        object_id = format '0x%016x', parameter.object_id
        assert_equal "#<Vissen::Parameterized::Parameter:#{object_id} " \
                     'real:(0.0*)>', parameter.inspect
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

    describe '#unbind' do
      it 'copies the value of the target to the constant' do
        parameter.unbind
        assert parameter.constant?
        assert_equal target.value, parameter.value
      end
    end

    describe '#type' do
      it 'returns the value type of the parameter' do
        assert_same value_klass, parameter.type
      end
    end

    describe '#to_s' do
      it 'returns the string value' do
        target.untaint!
        assert_equal "{#{target}}", parameter.to_s
      end
    end

    describe '#inspect' do
      it 'returns a string representation of the parameter' do
        object_id = format '0x%016x', parameter.object_id
        assert_equal "#<Vissen::Parameterized::Parameter:#{object_id} " \
                     "real:{#{target}}>", parameter.inspect
      end
    end

    describe '#tainted?' do
      let(:parameter_a) { subject.new value_klass }
      let(:parameter_b) { subject.new value_klass }

      before do
        parameter_a.bind target
        parameter_b.bind parameter_a
      end

      it 'works with multiple levels' do
        assert parameter_b.tainted?
        assert_equal target.value, parameter_b.value

        target.write 24
        assert_equal target.value, parameter_b.value
      end
    end
  end
end
