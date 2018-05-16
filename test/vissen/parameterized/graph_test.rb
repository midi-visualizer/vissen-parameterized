# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Graph do
  subject { Vissen::Parameterized::Graph }

  let(:cond_klass) { Vissen::Parameterized::Conditional }
  let(:real_klass) { Vissen::Parameterized::Value::Real }
  let(:bool_klass) { Vissen::Parameterized::Value::Bool }
  let(:cond_a)     { cond_klass.new(real_klass) { |v| v < 2 } }
  let(:cond_b)     { cond_klass.new(bool_klass, &:!) }
  let(:cond_false) { cond_klass.new(bool_klass) { false } }

  let(:global_scope) { Vissen::Parameterized::GlobalScope.instance }
  let(:scope)        { global_scope.create_scope cond_false }
  let(:scope_error)  { Vissen::Parameterized::ScopeError }

  let(:graph) { subject.new [cond_b, cond_false] }

  before do
    cond_b.bind :input, cond_a
  end

  describe '.new' do
    let(:cond_c) { cond_klass.new(bool_klass, scope: scope) { |v| v } }

    it 'raises a ScopeError if one end node is out of scope' do
      assert_raises(scope_error) { subject.new [cond_b, cond_c] }
    end

    it 'accepts a scope' do
      assert_silent { subject.new [cond_b, cond_c], scope: scope }
    end
  end

  describe '#update!' do
    it 'sets and untaints all values' do
      graph.update!

      assert cond_a.value
      refute cond_b.value
      refute cond_false.value

      cond_a.set :input, 3
      graph.update!

      refute cond_a.value
      assert cond_b.value
      refute cond_false.value

      refute cond_a.tainted?
      refute cond_b.tainted?
      refute cond_false.tainted?
    end

    it 'yields the output values of the end nodes' do
      res = []
      graph.update! { |v| res << v }
      assert_equal [false, false], res
    end
  end
end
