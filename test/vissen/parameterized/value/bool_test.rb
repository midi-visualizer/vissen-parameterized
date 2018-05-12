# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Value::Bool do
  subject    { Vissen::Parameterized::Value::Bool }
  let(:bool) { subject.new }

  describe '.new' do
    it 'defaults to false' do
      assert_same false, bool.value
    end

    it 'coerces truthy arguemnts to a true boolean' do
      bool = subject.new 42
      assert_same true, bool.value
    end

    it 'coerces falsy arguemnts to a false boolean' do
      bool = subject.new nil
      assert_same false, bool.value
    end
  end
end
