# frozen_string_literal: true

module Vissen
  module Parameterized
    module Value
      # Int values are stored as Fixnums internally.
      #
      # === Usage
      #
      #   int = Int.new 42
      #   int.value # => 42
      #
      class Int
        include Value

        # @return [Fixnum] see Value
        DEFAULT = 0

        # @raise  [TypeError] if the given object cannot be coerced into an
        #   integer.
        #
        # @param  new_value [#to_i] the new value.
        # @return see Value#write
        def write(new_value)
          super Integer(new_value)
        end
      end
    end
  end
end
