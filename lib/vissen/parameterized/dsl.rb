# frozen_string_literal: true

module Vissen
  module Parameterized
    # This module provides a DSL for defining input parameters and output values
    # for parameterized objects.
    #
    # == Usage
    #
    #   class Example
    #     extend DSL
    #
    #     param input:  Value::Vec,
    #           offset: Value::Real
    #   end
    #
    module DSL
      # @param  key [Symbol] the parameter to add.
      # @param  value_klass [Class] the value type of the parameter.
      # @param  default [Object] the default value of the parameter.
      # @return [nil]
      def param(key, value_klass, default: nil)
        @_params = {} unless defined? @_params
        @_params[key] = [value_klass, default].freeze
        nil
      end

      # @param  value_klass [Class] the value class to use.
      # @return [nil]
      def output(value_klass)
        @_output = value_klass
        nil
      end

      # @return [Hash<Symbol, Parameter>] a new hash containing one parameter
      #   object for each parameter key.
      def class_parameters
        return {}.freeze unless defined? @_params

        @_params.each_with_object({}) { |(k, v), h| h[k] = Parameter.new(*v) }
                .freeze
      end

      # @raise  [RuntimeError] if no output class has been defined.
      #
      # @return [Value, nil] a new instance of the value class defined using
      #   `#output`, or nil if nothing was defined.
      def class_output
        return nil unless defined? @_output
        @_output.new
      end

      # Dynamically adds a `.new` method to the extending module (or class), if
      # it is a descendent of Parameterized, that initializes the input
      # parameters and the output value.
      #
      # @param  mod [Module] the module that extended the DSL.
      def self.extended(mod)
        define_param_types mod
        return unless mod <= Parameterized

        mod.define_singleton_method :new do |*args, **opts|
          super(*args,
                parameters: class_parameters,
                output: class_output,
                **opts)
        end
      end

      private_class_method :extended

      # Defines custom param methods for each class that includes the `Value`
      # module.
      #
      # @param  mod [Module] the module to define the types on.
      def self.define_param_types(mod)
        Value.types.each do |klass|
          name = class_to_sym klass
          mod.define_singleton_method name do |key, **opts|
            param(key, klass, **opts)
          end
        end
      end

      private_class_method :define_param_types

      # Converts a class name to a symbol.
      #
      #   Vissen::Parameterized::Value::Real -> :real
      #
      # @param  klass [Class] the class to symbolize.
      # @return [Symbol] a symbolized version of the class name.
      def self.class_to_sym(klass)
        Value.canonicalize(klass).to_sym
      end

      private_class_method :class_to_sym
    end
  end
end
