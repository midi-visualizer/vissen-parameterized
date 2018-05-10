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

      # @return [Hash<Symbol, Parameter>] a new hash containing one parameter
      #   object for each parameter key.
      def class_parameters
        return {}.freeze unless defined? :@_params

        @_params.each_with_object({}) { |(k, v), h| h[k] = Parameter.new v }
                .freeze
      end
    end
  end
end
