# frozen_string_literal: true

module Vissen
  module Parameterized
    module Value
      # Bool values are stored as booleans internally.
      #
      # === Usage
      #
      #   bool = Bool.new true
      #   bool.value # => true
      #
      class Bool
        include Value

        # @return [true, false] see Value
        DEFAULT = false

        # @param  new_value [Object] the new value.
        # @return see Value#write
        def write(new_value)
          super new_value ? true : false
        end
      end
    end
  end
end
