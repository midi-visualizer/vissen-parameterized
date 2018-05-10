# frozen_string_literal: true

module Vissen
  module Parameterized
    module Value
      # Vector type values are stored internally as arrays of floats.
      #
      # === Usage
      #
      #   vec = Vec[1, 0.2]
      #   vec.value # => [1.0, 0.2]
      #
      class Vec
        include Value

        # @return [Array<Float>] the default value that will be used when `.new`
        #   is called without arguments, or with nil.
        DEFAULT = [0.0, 0.0].freeze

        # @param  initial_value [Array<#to_f>] the initial value to use.
        def initialize(initial_value = nil)
          @value   = DEFAULT.dup
          @tainted = true

          write initial_value if initial_value
        end

        # @raise  [TypeError] if the given value does not respond to `#[]`.
        # @raise  [TypeError] if the elements of the given value does not cannot
        #   be coerced into floats.
        #
        # @param  new_value [Array<#to_f>] the new values to write.
        # @return [nil]
        def write(new_value)
          return if @value == new_value

          @tainted = true

          @value[0] = Float(new_value[0])
          @value[1] = Float(new_value[1])
          nil
        rescue NoMethodError
          raise TypeError, 'The given object must support #[]'
        end

        class << self
          # @param  a [#to_f] the first vector component.
          # @param  b [#to_f] the second vector component.
          # @return [Vec] a new Vec instance.
          def [](a, b)
            new [a, b]
          end
        end
      end
    end
  end
end
