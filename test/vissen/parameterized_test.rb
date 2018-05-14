# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized do
  subject { TestHelper::ParameterizedMock }

  let(:real_class) { Vissen::Parameterized::Value::Real }
  let(:param_a)    { Vissen::Parameterized::Parameter.new real_class }
  let(:param_b)    { Vissen::Parameterized::Parameter.new real_class }
  let(:target)     { real_class.new 3 }
  let(:params)     { { a: param_a, b: param_b } }
  let(:output)     { real_class.new }

  let(:global_scope) { Vissen::Parameterized::GlobalScope.instance }
  let(:conditional)  { Vissen::Parameterized::Conditional.new { true } }
  let(:scope)        { global_scope.create_scope conditional }

  let(:parameterized) { subject.new parameters: params, output: output }

  before do
    param_a.set 1
    param_b.set 2
  end

  it 'has a version number' do
    refute_nil ::Vissen::Parameterized::VERSION
  end

  describe '.new' do
    it 'uses the global scope by default' do
      assert_same global_scope, parameterized.scope
    end

    it 'accepts an optional scope' do
      parameterized = subject.new parameters: params,
                                  output: output,
                                  scope: scope

      assert_same scope, parameterized.scope
    end
  end

  describe '#call' do
    it 'raises a NotImplementedError if call is not overridden' do
      assert_raises(NotImplementedError) { parameterized.call nil }
    end
  end

  describe '#parameters' do
    it 'returns a parameter accessor' do
      accessor = parameterized.parameters

      assert_same param_a.value, accessor.a
      assert_same param_b.value, accessor.b
    end
  end

  describe '#untaint!' do
    it 'untaints the parameters' do
      assert param_a.tainted?
      assert param_b.tainted?
      assert output.tainted?

      parameterized.untaint!

      refute param_a.tainted?
      refute param_b.tainted?
      refute output.tainted?
    end
  end

  describe '#tainted?' do
    before do
      @called = false
      ctx = self
      parameterized.define_singleton_method :call do |params|
        ctx.instance_variable_set :@called, true
        params.a + params.b
      end
    end

    it 'returns true but does not update the value' do
      assert parameterized.tainted?
      assert_equal (1 + 2), output.value
    end

    it 'returns false when no parameters have changed' do
      parameterized.untaint!
      refute parameterized.tainted?
    end

    it 'returns true when parameters have changed' do
      parameterized.untaint!
      param_a.set 2
      assert parameterized.tainted?
    end

    it 'does not update the value twice' do
      @called = false
      parameterized.tainted?
      assert @called
      @called = false
      parameterized.tainted?
      refute @called
    end

    it 'works when chaining multiple objects' do
      root = subject.new parameters: { c: parameterized },
                         output: real_class.new
      root.define_singleton_method(:call) { |params| -params.c }

      assert root.tainted?
      assert_equal(-3, root.value)
    end
  end

  describe '#bind' do
    it 'binds the parameter to the target' do
      parameterized.bind :a, target
      refute param_a.constant?
    end

    it 'raises a KeyError for unknown parameters' do
      assert_raises(KeyError) { parameterized.bind :unknown, target }
    end

    it 'raises a RuntimeError when binding outside the scope' do
      other = subject.new parameters: params,
                          output: output,
                          scope: scope

      assert_raises(RuntimeError) { parameterized.bind :a, other }
    end
  end

  describe '#set' do
    it 'sets the parameter to the given value' do
      parameterized.set :a, 5.6
      assert param_a.constant?
      assert_equal 5.6, param_a.value
    end

    it 'raises a KeyError for unknown parameters' do
      assert_raises(KeyError) { parameterized.set :unknown, 0 }
    end
  end

  describe '#returns_a?' do
    it 'returns true when the output class matches' do
      assert parameterized.returns_a? real_class
    end

    it 'returns false when the output class does not match' do
      refute parameterized.returns_a? Class.new
    end
  end
end
