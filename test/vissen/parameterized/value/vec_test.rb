# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Value::Vec do
  subject { Vissen::Parameterized::Value::Vec }
  let(:vec) { subject.new }

  describe '.new' do
    it 'defaults to [0.0, 0.0]' do
      assert_equal [0.0, 0.0], vec.value
    end

    it 'coerces arguemnts to a float' do
      vec = subject.new [42, 0.3]
      assert_equal [42.0, 0.3], vec.value
    end

    it 'marks the value as tainted' do
      assert vec.tainted?
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
      vec.untaint!
      vec.write [rand, rand]
      assert vec.tainted?
    end

    it 'does not taint the value if the same value is written' do
      vec.untaint!
      vec.write vec.value
      refute vec.tainted?
    end

    it 'raises a TypeError for invalid arrays' do
      assert_raises(TypeError) { vec.write [0] }
    end

    it 'raises a TypeError for unknown objects' do
      assert_raises(TypeError) { subject.new Object.new }
    end
  end

  describe '#to_s' do
    let(:vec) { subject.new [42, 0.3] }

    it 'returns the value of the vector as a string when tainted' do
      assert_equal '[42.0, 0.3]*', vec.to_s
    end

    it 'returns the value of the vector as a string when untainted' do
      vec.untaint!
      assert_equal '[42.0, 0.3]', vec.to_s
    end
  end
end
