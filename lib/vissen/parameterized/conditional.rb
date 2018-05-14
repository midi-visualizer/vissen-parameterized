# frozen_string_literal: true

module Vissen
  module Parameterized
    # The conditional is just a specialized form of a parameterized object. It
    # takes just one input and, through a given block, transforms it to a
    # boolean value. The aliased method `#met?` is nothing more than syntactic
    # suger for and equivalent to calling `#value`.
    #
    # === Usage
    # The following exable sets up a conditional, binds it to a value and checks
    # if the condition is met for two different values. The update proceedure is
    # the same as with other parameterized objects.
    #
    #   less_than_two = Conditional.new { |value| value < 2 }
    #   value = Value::Real.new 1
    #   less_than_two.bind :input, value
    #
    #   less_than_two.tainted? # => true
    #   less_than_two.met? # => true
    #   less_than_two.untaint!
    #
    #   value.write 3
    #   less_than_two.tainted? # => true
    #   less_than_two.met? # => false
    #
    class Conditional
      include Parameterized

      # @!method met?
      # @return [true, false] the state of the conditional.
      alias met? value

      # @param  input_klass [Class] the value class of the input parameter.
      # @param  opts (see Parameterized)
      def initialize(input_klass = Value::Real, **opts)
        super(parameters: { input: Parameter.new(input_klass) },
              output: Value::Bool.new,
              **opts)

        define_singleton_method :call do |params|
          yield params.input
        end
      end

      # Forces the state of the output to the given value. The input is unbound
      # and untainted to prevent it from affecting the output further.
      #
      # @param  value [true, false] the value to force.
      # @return [true] if the output was changed.
      # @return [false] otherwise.
      def force!(value = true)
        input = @_params[:input]
        input.unbind unless input.constant?
        input.untaint!

        @_value.write value
      end
    end
  end
end
