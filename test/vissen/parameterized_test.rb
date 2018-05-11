# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized do
  subject { TestHelper::ParameterizedMock }
  
  let(:mod)                   { Vissen::Parameterized::Value }
  let(:first_transaction_id)  { mod.next_transaction_id }
  let(:second_transaction_id) { mod.next_transaction_id first_transaction_id }
  
  let(:real_class) { Vissen::Parameterized::Value::Real }
  let(:param_a)    { Vissen::Parameterized::Parameter.new real_class }
  let(:param_b)    { Vissen::Parameterized::Parameter.new real_class }
  let(:params)     { { a: param_a, b: param_b } }
  let(:output)     { real_class.new }
  
  let(:parameterized) { subject.new }
  
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
  
  describe '#parameters=' do
    it 'accepts a hash of parameters' do
      parameterized.parameters = params
      assert_same params, parameterized.parameters
    end
  end
  
  describe '#tainted?' do
    before do
      @called = false
      parameterized.parameters = params
      parameterized.output = output
      parameterized.define_singleton_method :call do |params|
        @called = true
        params[:a].value + params[:b].value
      end
    end
    
    it 'returns true but does not update the value' do
      assert parameterized.tainted? first_transaction_id
      refute @called
    end
    
    it 'returns false when no parameters have changed' do
      refute parameterized.tainted? second_transaction_id
    end
    
    it 'returns true when parameters have changed' do
      assert parameterized.tainted? first_transaction_id
      param_a.tainted? second_transaction_id
      param_a.set 2
      assert parameterized.tainted? second_transaction_id
    end
  end
end
