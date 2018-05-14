# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::GlobalScope do
  subject { Vissen::Parameterized::GlobalScope }

  let(:scope)       { subject.instance }
  let(:value_klass) { Vissen::Parameterized::Value::Real }
  let(:conditional) do
    Vissen::Parameterized::Conditional.new(value_klass) { true }
  end

  describe '#alive?' do
    it 'returns true' do
      assert scope.alive?
    end
  end

  describe '#dead?' do
    it 'returns false' do
      refute scope.dead?
    end
  end

  describe '#kill!' do
    it 'raises a runtime error' do
      assert_raises(RuntimeError) { scope.kill! }
    end
  end

  describe '#create_scope' do
    it 'returns a new child scope' do
      child = scope.create_scope conditional
      assert_kind_of Vissen::Parameterized::Scope, child
      assert_same scope, child.parent
    end
  end

  describe '#include_scope?' do
    it 'includes itself' do
      assert scope.include_scope? scope
    end
  end

  describe '#parent' do
    it 'raises a StopIteration' do
      assert_raises(StopIteration) { scope.parent }
    end
  end
end
