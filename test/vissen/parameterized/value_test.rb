# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Value do
  subject { TestHelper::ValueMock }
  let(:value_mock) { subject.new }

  describe '.new' do
    it 'accepts an initial value' do
      value = subject.new 42
      assert_equal 42, value.value
    end

    it 'defaults to the value stored in DEFAULT' do
      assert_equal subject::DEFAULT, value_mock.value
    end

    it 'marks the value as tainted' do
      assert value_mock.tainted?
    end

    it 'supports boolean false' do
      value = subject.new false
      assert_equal false, value.value
    end
  end

  describe '#write' do
    it 'updates the value' do
      value_mock.write 42
      assert_equal 42, value_mock.value
    end

    it 'taints untainted values' do
      value_mock.untaint!
      value_mock.write rand
      assert value_mock.tainted?
    end

    it 'does not taint the value if the same value is written' do
      value_mock.untaint!
      value_mock.write value_mock.value
      refute value_mock.tainted?
    end
  end

  describe '#untaint!' do
    it 'untaints values' do
      value_mock.untaint!
      refute value_mock.tainted?
    end
  end
end
