# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Scope do
  subject { Vissen::Parameterized::Scope }

  let(:global_scope) { Vissen::Parameterized::GlobalScope.instance }
  let(:value_klass) { Vissen::Parameterized::Value::Real }
  let(:conditional_klass) { Vissen::Parameterized::Conditional }
  let(:conditional) { conditional_klass.new(value_klass) { true } }
  let(:scope) { global_scope.create_scope conditional }

  describe '.new' do
    it 'raises a TypeError for invalid conditionals' do
      assert_raises(TypeError) { global_scope.create_scope Object.new }
    end

    it 'raises a RuntimeError if the conditional is badly scoped' do
      conditional = conditional_klass.new(value_klass, scope: scope) { true }
      assert_raises(RuntimeError) { global_scope.create_scope conditional }
    end
  end

  describe '#alive?' do
    it 'returns true initially' do
      assert scope.alive?
    end

    it 'returns false once the conditional is met' do
      assert conditional.tainted?
      refute scope.alive?
    end
  end

  describe '#dead?' do
    it 'returns false initially' do
      refute scope.dead?
    end

    it 'returns true once the conditional is met' do
      assert conditional.tainted?
      assert scope.dead?
    end

    it 'returns true if the parent is dead' do
      child_conditional = conditional_klass.new(value_klass) { false }
      child = scope.create_scope child_conditional

      assert conditional.tainted?
      refute child_conditional.tainted?

      assert scope.dead?
      assert child.dead?
    end
  end

  describe '#kill!' do
    it 'kills the scope' do
      refute scope.dead?
      scope.kill!
      assert scope.dead?
    end
  end

  describe '#create_scope' do
    it 'returns a new child scope' do
      child = scope.create_scope conditional
      assert_kind_of subject, child
      assert_same scope, child.parent
    end
  end

  describe '#include_scope?' do
    it 'includes itself' do
      assert scope.include_scope? scope
    end

    it 'includes the global scope' do
      assert scope.include_scope? global_scope
    end
  end
end
