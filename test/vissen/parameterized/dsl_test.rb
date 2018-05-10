# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::DSL do
  subject { TestHelper::DSLMock }

  let(:parameter_klass) { Vissen::Parameterized::Parameter }
  let(:real_klass)      { Vissen::Parameterized::Value::Real }
  let(:vec_klass)       { Vissen::Parameterized::Value::Vec }

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
end
