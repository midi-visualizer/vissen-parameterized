# frozen_string_literal: true

require 'test_helper'

describe Vissen::Parameterized::Conditional do
  subject { Vissen::Parameterized::Conditional }

  let(:value_klass) { Vissen::Parameterized::Value::Real }
  let(:conditional) { subject.new(value_klass) { |value| value < 2 } }
  let(:input)       { value_klass.new }

  before do
    conditional.bind :input, input
    conditional.untaint!
  end

  describe '#met?' do
    it 'returns false when the block returns false' do
      input.write 3
      refute conditional.tainted?
      refute conditional.met?
    end

    it 'returns true when the block returns true' do
      input.write 1
      assert conditional.tainted?
      assert conditional.met?
    end
  end
end
