# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized do
  subject { TestHelper::ParameterizedMock }

  let(:real_class) { Vissen::Parameterized::Value::Real }
  let(:vec_class)  { Vissen::Parameterized::Value::Vec }
  let(:param_a)    { Vissen::Parameterized::Parameter.new real_class }
  let(:param_b)    { Vissen::Parameterized::Parameter.new real_class }
  let(:target)     { real_class.new 3 }
  let(:params)     { { a: param_a, b: param_b } }
  let(:output)     { real_class.new }

  let(:global_scope) { Vissen::Parameterized::GlobalScope.instance }
  let(:conditional)  { Vissen::Parameterized::Conditional.new { true } }
  let(:scope)        { global_scope.create_scope conditional }
  let(:scope_error)  { Vissen::Parameterized::ScopeError }

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

    it 'accepts a hash of initial values' do
      parameterized = subject.new parameters: params,
                                  output: output,
                                  setup: { a: 4.2, b: target }

      param_a.tainted?
      param_b.tainted?

      assert_same 4.2, parameterized.parameters.a
      assert_same 3.0, parameterized.parameters.b
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
    before do
      parameterized.define_singleton_method(:call) { |_| 1.0 }
    end

    it 'untaints the parameters' do
      assert param_a.tainted?
      assert param_b.tainted?
      assert output.tainted?
      assert parameterized.tainted?

      parameterized.untaint!

      refute param_a.tainted?
      refute param_b.tainted?
      refute output.tainted?
      refute parameterized.tainted?
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
      assert parameterized.tainted?
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

    it 'works when chaining two objects' do
      root = subject.new parameters: { c: parameterized },
                         output: real_class.new
      root.define_singleton_method(:call) { |params| -params.c }

      assert root.tainted?
      assert_equal(-3, root.value)

      root.untaint!

      param_a.set 2
      assert root.tainted?
      assert_equal(-4, root.value)
    end

    it 'works when chaining many objects' do
      c = Vissen::Parameterized::Parameter.new real_class
      root =
        5.times.reduce(parameterized) do |a, _|
          node = subject.new parameters: { a: a, c: c }, output: real_class.new
          node.define_singleton_method(:call) { |p| 2 * (p.a + p.c) }
          node
        end

      assert root.tainted?
      assert_equal(96, root.value)

      root.untaint!

      param_b.set 1
      assert root.tainted?
      assert_equal(64, root.value)

      root.untaint!

      c.set 2
      assert root.tainted?
      assert_equal(188, root.value)
    end

    # This test reproduces a bug that was discovered when using the library
    # elsewhere.
    it 'reproduces a certain bug' do
      real_param_a = Vissen::Parameterized::Parameter.new real_class
      real_param_b = Vissen::Parameterized::Parameter.new real_class
      vec_param = Vissen::Parameterized::Parameter.new vec_class

      real = subject.new parameters: { vec: vec_param },
                         output: real_class.new
      real.define_singleton_method(:call) { |p| p.vec[0] + p.vec[1] }

      vec = subject.new parameters: { a: real_param_a, b: real_param_b },
                        output: vec_class.new
      vec.define_singleton_method(:call) { |p| [p.a, p.b] }

      real.bind(:vec, vec)
      real.tainted?
      real.untaint!

      vec.set :a, 0.5

      assert real.tainted?
      assert_equal 0.5, real.value
    end
  end

  describe '#parameter?' do
    it 'returns true when the parameter exists' do
      assert parameterized.parameter? :a
    end

    it 'returns false when the parameter does not exist' do
      refute parameterized.parameter? :c
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

    it 'raises a ScopeError when binding outside the scope' do
      other = subject.new parameters: params,
                          output: output,
                          scope: scope

      assert_raises(scope_error) { parameterized.bind :a, other }
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

  describe '#each_parameterized' do
    let(:param_c) { Vissen::Parameterized::Parameter.new real_class }

    it 'returns an enumerator when not given a block' do
      enum = parameterized.each_parameterized
      assert_kind_of Enumerator, enum
    end

    it 'yields nothing without parameterized object among the parameters' do
      enum = parameterized.each_parameterized
      assert_raises(StopIteration) { enum.next }
    end

    it 'yields each parameterized object among the parameters' do
      root = subject.new parameters: { a: param_a, c: param_c },
                         output: real_class.new
      param_c.bind parameterized
      count = 0
      root.each_parameterized do |obj|
        assert_same obj, parameterized
        count += 1
      end
      assert_equal 1, count
    end
  end

  describe '#to_s' do
    it 'returns the string representation of the output value' do
      assert_equal output.to_s, parameterized.to_s
    end
  end

  describe '#inspect' do
    it 'returns a string representation of the parameterized object' do
      str       = parameterized.inspect
      object_id = format '0x%016x', parameterized.object_id

      assert_equal "#<TestHelper::ParameterizedMock:#{object_id} " \
                   '(a:real, b:real) -> real>', str
    end
  end
end
