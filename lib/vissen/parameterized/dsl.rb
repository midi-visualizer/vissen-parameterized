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
      # @return [Value] a new instance of the value class defined using
      #   `#output`.
      def class_output
        raise 'No output class defined' unless defined? @_output
        @_output.new
      end

      # Dynamically adds a `.new` method to the extending module (or class), if
      # it is a descendent of Parameterized, that initializes the input
      # parameters and the output value.
      #
      # @param  mod [Module] the module that extended the DSL.
      def self.extended(mod)
        return unless mod <= Parameterized
        mod.define_singleton_method :new do |*args, **opts|
          super(*args,
                parameters: class_parameters,
                output: class_output,
                **opts)
        end
      end
    end
  end
end
