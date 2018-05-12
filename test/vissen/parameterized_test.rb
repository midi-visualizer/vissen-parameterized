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

  let(:parameterized) { subject.new parameters: params, output: output }

  before do
    param_a.set 1
    param_b.set 2
  end

  it 'has a version number' do
    refute_nil ::Vissen::Parameterized::VERSION
  end

  describe '#call' do
    it 'raises a NotImplementedError if call is not overridden' do
      assert_raises(NotImplementedError) { parameterized.call nil }
    end
  end

  # describe '#parameters=' do
  #   it 'accepts a hash of parameters' do
  #     parameterized.parameters = params
  #     assert_same params, parameterized.parameters
  #   end
  # end

  describe '#untaint!' do
    # before do
    #   parameterized.parameters = params
    #   parameterized.output = output
    # end

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
      # parameterized.parameters = params
      # parameterized.output = output
      ctx = self
      parameterized.define_singleton_method :call do |params|
        ctx.instance_variable_set :@called, true
        params[:a].value + params[:b].value
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
      root = subject.new parameters: { c: parameterized }, output: real_class.new
      root.define_singleton_method(:call) { |params| -params[:c].value }

      assert root.tainted?
      assert_equal(-3, root.value)
    end
  end

  describe '#bind' do
    # before do
    #   parameterized.parameters = params
    #   parameterized.output = output
    # end

    it 'binds the parameter to the target' do
      parameterized.bind :a, target
      refute param_a.constant?
    end

    it 'raises a KeyError for unknown parameters' do
      assert_raises(KeyError) { parameterized.bind :unknown, target }
    end
  end
end
