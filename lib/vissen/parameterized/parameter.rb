# frozen_string_literal: true

module Vissen
  module Parameterized
    # Parameter respond to #value and can either return a locally stored
    # constant or the value of a target object.
    #
    # === Usage
    #
    #   parameter = Parameter.new Value::Real
    #   parameter.set 42
    #   parameter.value # => 42
    #
    #   target = Value::Real.new 4.2
    #   parameter.bind target
    #   parameter.value # => 4.2
    #
    class Parameter
      extend Forwardable

      def_delegators :@target, :value, :tainted?

      # @param  value_klass [Class] the value type supported by the parameter.
      def initialize(value_klass)
        @constant = value_klass.new
        clear!
      end

      # Unbinds the parameter and resets the value of the to the default of the
      #   value class.
      #
      # @return [self]
      def clear!
        set @constant.class::DEFAULT
      end

      # @return [false] if the parameter is bound to a value object.
      # @reutrn [true] otherwise.
      def constant?
        @constant.equal? @target
      end

      # @raise  [RuntimeError] if the parameter is constant.
      #
      # @return [#value] the value target.
      def target
        raise RuntimeError if constant?
        @target
      end

      # Writes a constant value to the parameter.
      #
      # @param  value [Object] the value to set.
      # @return [self]
      def set(value)
        @constant.write value
        @target = @constant
        self
      end

      # TODO: validate the value type
      #
      # @param  obj [#value] the value object to bind to.
      # @return [self]
      def bind(obj)
        raise TypeError unless obj.respond_to?(:value)
        @target = obj
        self
      end
    end
  end
end
