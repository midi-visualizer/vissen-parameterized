# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::DSL do
  subject { TestHelper::DSLMock.dup }

  let(:parameter_klass) { Vissen::Parameterized::Parameter }
  let(:real_klass)      { Vissen::Parameterized::Value::Real }
  let(:vec_klass)       { Vissen::Parameterized::Value::Vec }

  let(:global_scope)    { Vissen::Parameterized::GlobalScope.instance }
  let(:conditional) do
    Vissen::Parameterized::Conditional.new(real_klass) { false }
  end
  let(:scope) { global_scope.create_scope conditional }

  describe '.param' do
    it 'accepts a hash' do
      subject.param real: real_klass,
                    vec:  vec_klass
    end
  end

  describe '.class_parameters' do
    before do
      subject.param real: real_klass,
                    vec:  vec_klass
    end

    let(:parameters) { subject.class_parameters }

    it 'returns a hash of parameters' do
      assert_kind_of parameter_klass, parameters[:real]
      assert_kind_of parameter_klass, parameters[:vec]
    end

    it 'uses the parameter classes' do
      assert_equal real_klass::DEFAULT, parameters[:real].value
      assert_equal vec_klass::DEFAULT, parameters[:vec].value
    end
  end

  describe '.class_output' do
    it 'raises a RuntimeError if no outut is defined' do
      assert_raises(RuntimeError) { subject.class_output }
    end

    it 'returns a new instance of the output class' do
      subject.output real_klass
      assert_kind_of real_klass, subject.class_output
    end
  end

  describe '.new' do
    before do
      subject.output real_klass
      subject.param real: real_klass
    end

    let(:instance) { subject.new }

    it 'sets the output of the new instance' do
      assert_equal real_klass::DEFAULT, instance.value
    end

    it 'sets the parameters of the new instance' do
      assert_equal real_klass::DEFAULT, instance.parameters.real
    end

    it 'accepts a scope' do
      instance = subject.new scope: scope
      assert_same scope, instance.scope
    end
  end
end
