# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Value::Vec do
  subject { Vissen::Parameterized::Value::Vec }
  let(:vec) { subject.new }
  let(:first_transaction_id)  { 1 }
  let(:second_transaction_id) { first_transaction_id + 1 }

  describe '.new' do
    it 'defaults to [0.0, 0.0]' do
      assert_equal [0.0, 0.0], vec.value
    end

    it 'coerces arguemnts to a float' do
      vec = subject.new [42, 0.3]
      assert_equal [42.0, 0.3], vec.value
    end

    it 'marks the value as tainted' do
      assert vec.tainted? first_transaction_id
    end
  end

  describe '.[]' do
    it 'returns a new Vec' do
      vec = subject[4, 2]
      assert_equal [4.0, 2.0], vec.value
    end
  end

  describe '#write' do
    it 'updates the value' do
      vec.write [42, 0.3]
      assert_equal [42, 0.3], vec.value
    end

    it 'does not store the given array but copies the values' do
      arr = [rand, rand]
      vec.write arr
      refute_same arr, vec.value
    end

    it 'taints untainted values' do
      refute vec.tainted? second_transaction_id
      vec.write [rand, rand]
      assert vec.tainted? second_transaction_id
    end

    it 'does not taint the value if the same value is written' do
      refute vec.tainted? second_transaction_id
      vec.write vec.value
      refute vec.tainted? second_transaction_id
    end

    it 'raises a TypeError for invalid arrays' do
      assert_raises(TypeError) { vec.write [0] }
    end

    it 'raises a TypeError for unknown objects' do
      assert_raises(TypeError) { subject.new Object.new }
    end
  end
end
