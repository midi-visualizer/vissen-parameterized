# frozen_string_literal: true

module Vissen
  module Parameterized
    # The Value module implements the basic functionallity of a value type.
    # Class implementations are encouraged to override #write to provide type
    # checking or coercion.
    #
    # === Usage
    # The following example implements an integer type by calling #to_i on
    # objects before they are written.
    #
    #   class Int
    #     include Value
    #     DEFAULT = 0
    #
    #     def write(new_value)
    #       super new_value.to_i
    #     end
    #   end
    #
    module Value
      # @return [Object] the internal value object.
      attr_reader :value

      # @return [Object] the default value that will be used when `.new` is
      #   called without arguments, or with nil.
      DEFAULT = nil

      # @param  value [Object] the initial value to use. Ignored if nil.
      def initialize(value = nil)
        @value   = nil
        @tainted = true

        write(value.nil? ? self.class::DEFAULT : value)
      end

      # Updates the internally stored value. The object will be marked as
      # tainted if the new value differs from the previous.
      #
      # @param  new_value [Object] the new value to write.
      # @return [true] if the value was changed.
      # @return [false] otherwise.
      def write(new_value)
        return false if new_value == @value
        @value = new_value
        taint!
        true
      end

      # @return [true] if the value has been written to since the last call to
      #   `#untaint!`.
      # @return [false] otherwise.
      def tainted?
        @tainted
      end

      # Marks the value as untainted.
      #
      # @return [false]
      def untaint!
        @tainted = false
      end

      # Values are always considered part of the global scope.
      #
      # @return [Scope] the scope of the value.
      def scope
        GlobalScope.instance
      end

      # @return [Array<Module>] an array of the modules and classes that include
      #   the `Value` module.
      def self.types
        @types
      end

      # Converts a class name to a string.
      #
      #   Vissen::Parameterized::Value::Real -> "real"
      #
      # @param  klass [Class] the class to canonicalize.
      # @return [String] a string version of the class name.
      def self.canonicalize(klass)
        klass.name
             .split('::').last
             .gsub(/([a-z\d])([A-Z])/, '\1_\2')
             .downcase
      end

      # @return [String] the value formated as a string, with an appended '*' if
      #   the value is tainted.
      def to_s
        base = @value.to_s
        tainted? ? base + '*' : base
      end

      protected

      def taint!
        @tainted = true
      end

      # @param  mod [Module]
      def self.included(mod)
        (@types ||= []) << mod
      end

      private_class_method :included
    end
  end
end
