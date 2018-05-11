# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Value do
  subject { TestHelper::ValueMock }
  let(:value_mock) { subject.new }

  let(:mod)                   { Vissen::Parameterized::Value }
  let(:first_transaction_id)  { mod.next_transaction_id }
  let(:second_transaction_id) { mod.next_transaction_id first_transaction_id }

  describe '.new' do
    it 'accepts an initial value' do
      value = subject.new 42
      assert_equal 42, value.value
    end

    it 'defaults to the value stored in DEFAULT' do
      assert_equal subject::DEFAULT, value_mock.value
    end

    it 'marks the value as tainted' do
      assert value_mock.tainted? first_transaction_id
    end

    it 'supports boolean false' do
      value = subject.new false
      assert_equal false, value.value
    end
  end

  describe '.next_transaction_id' do
    it 'skips id 0' do
      assert_equal 1, mod.next_transaction_id(mod::TRANSACTION_ID_MASK)
    end
  end

  describe '#write' do
    it 'updates the value' do
      value_mock.write 42
      assert_equal 42, value_mock.value
    end

    it 'taints untainted values' do
      refute value_mock.tainted? second_transaction_id
      value_mock.write rand
      assert value_mock.tainted? second_transaction_id
    end

    it 'does not taint the value if the same value is written' do
      refute value_mock.tainted? second_transaction_id
      value_mock.write value_mock.value
      refute value_mock.tainted? second_transaction_id
    end
    
    it 'returns true when the value is changed' do
      res = value_mock.write value_mock.value + 1
      assert res
    end
    
    it 'returns false when the value is unchanged' do
      res = value_mock.write value_mock.value
      refute res
    end
  end

  describe '#tainted?' do
    it 'returns false for a different transaction id' do
      refute value_mock.tainted? second_transaction_id
    end
  end

  describe '#tested?' do
    it 'returns true for the first transaction id' do
      assert value_mock.tested? first_transaction_id
      refute value_mock.tested? second_transaction_id
    end

    it 'returns true for the second transaction id once it is tested' do
      assert value_mock.tested? first_transaction_id
      value_mock.tainted? second_transaction_id
      assert value_mock.tested? second_transaction_id
    end
  end
end
