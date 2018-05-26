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
    it 'accepts a key and value class' do
      subject.param :real, real_klass
    end

    it 'accepts a default value' do
      subject.param :real, real_klass, default: 42
    end
  end

  describe 'custom value types' do
    describe '.bool' do
      it 'cretes a boolean parameter' do
        subject.bool :bool
        parameters = subject.class_parameters
        assert parameters[:bool]
        assert_same false, parameters[:bool].value
      end

      it 'accepts a default' do
        subject.bool :bool, default: true
        assert_same true, subject.class_parameters[:bool].value
      end
    end

    describe '.int' do
      it 'cretes an integer parameter' do
        subject.int :int
        parameters = subject.class_parameters
        assert parameters[:int]
        assert_same 0, parameters[:int].value
      end

      it 'accepts a default' do
        subject.int :int, default: 42
        assert_same 42, subject.class_parameters[:int].value
      end
    end

    describe '.real' do
      it 'cretes a real parameter' do
        subject.real :real
        parameters = subject.class_parameters
        assert parameters[:real]
        assert_same 0.0, parameters[:real].value
      end

      it 'accepts a default' do
        subject.real :real, default: 4.2
        assert_same 4.2, subject.class_parameters[:real].value
      end
    end

    describe '.vec' do
      it 'cretes a vec parameter' do
        subject.vec :vec
        parameters = subject.class_parameters
        assert parameters[:vec]
        assert_equal [0.0, 0.0], parameters[:vec].value
      end

      it 'accepts a default' do
        subject.vec :vec, default: [4.2, 1.0]
        assert_equal [4.2, 1.0], subject.class_parameters[:vec].value
      end
    end
  end

  describe '.class_parameters' do
    before do
      subject.param :real, real_klass
      subject.param :vec,  vec_klass
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
    it 'returns nil if no outut is defined' do
      assert_nil subject.class_output
    end

    it 'returns a new instance of the output class' do
      subject.output real_klass
      assert_kind_of real_klass, subject.class_output
    end
  end

  describe '.new' do
    before do
      subject.output real_klass
      subject.param :real, real_klass
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
