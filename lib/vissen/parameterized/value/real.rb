# frozen_string_literal: true

module Vissen
  module Parameterized
    module Value
      # Real values are stored as floats internally.
      #
      # === Usage
      #
      #   real = Real.new 42
      #   real.value # => 42.0
      #
      class Real
        include Value

        # @return [Float] see Value
        DEFAULT = 0.0

        # @raise  [TypeError] if the given object cannot be coerced into a
        #   float.
        #
        # @param  new_value [#to_f] the new value.
        # @return see Value#write
        def write(new_value)
          super Float(new_value)
        end
      end
    end
  end
end
