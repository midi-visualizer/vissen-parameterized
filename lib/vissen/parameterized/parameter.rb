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

      INSPECT_FORMAT = '#<%<name>s:0x%016<object_id>x %<type>s:%<value>s>'
      private_constant :INSPECT_FORMAT

      def_delegators :@target, :value, :tainted?, :untaint!, :scope

      # @param  value_klass [Class] the value type supported by the parameter.
      # @param  default_value [Object] the default constant value. It defaults
      #   to the default of the given value class.
      def initialize(value_klass, default_value = nil)
        @default  = default_value.nil? ? value_klass::DEFAULT : default_value
        @constant = value_klass.new @default
        @target   = @constant
      end

      # Unbinds the parameter and resets the value of the to the default of the
      #   value class.
      #
      # @return [self]
      def clear!
        set @default
      end

      # @return [false] if the parameter is bound to a value object.
      # @return [true] otherwise.
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

      # Copies the value of the target to the internal constant and unbinds from
      # the target.
      def unbind
        raise 'cannot unbind constant' if constant?
        set @target.value
      end

      # @return [Value] the value class of the parameter.
      def type
        @constant.class
      end

      # @return [String] the parameter value formated as a string wrapped either
      #   in `()` or `{}` depending on if the value is constant or bound.
      def to_s
        base = @target.to_s
        constant? ? "(#{base})" : "{#{base}}"
      end

      # Produces a readable string representation of the parameter object.
      #
      # @return [String] a string representation.
      def inspect
        format INSPECT_FORMAT, name: self.class.name,
                               object_id: object_id,
                               type: Value.canonicalize(type),
                               value: to_s
      end
    end
  end
end
