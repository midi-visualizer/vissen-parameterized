# frozen_string_literal: true

module Vissen
  module Parameterized
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
      # @param  hash [Hash] the parameter(s) to add.
      # @return [nil]
      def param(**hash)
        @_params ||= {}
        @_params.merge! hash
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

        @_params.each_with_object({}) { |(k, v), h| h[k] = Parameter.new v }
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
    end
  end
end
