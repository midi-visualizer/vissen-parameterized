# frozen_string_literal: true

require 'forwardable'

require 'vissen/parameterized/version'
require 'vissen/parameterized/value'
require 'vissen/parameterized/value/real'
require 'vissen/parameterized/value/vec'
require 'vissen/parameterized/parameter'
require 'vissen/parameterized/dsl'

module Vissen
  # A parameterized object should have
  # - a set of parameters,
  # - a (possibly expensive) function that transforms the parameters to an
  #   output, and
  # - an output value.
  #
  module Parameterized
    extend Forwardable

    def_delegators :@_value, :value

    def initialize(*)
      super

      @_visited = false
    end

    def call(_parameters)
      raise NotImplementedError
    end

    def parameters=(parameters)
      @_params = parameters
    end

    def parameters
      @_params
    end

    def output=(value)
      @_value = value
    end

    def untaint!
      @_visited = false
      # ASUMPTION: if the value is untainted the params must also be unchanged.
      return unless @_value.tainted?

      @_value.untaint!
      @_params.each { |_, param| param.untaint! }
    end

    def tainted?
      return @_value.tainted? if @_visited
      @_visited = true

      params_tainted =
        @_params.reduce(false) do |a, (_, param)|
          param.tainted? || a
        end

      # Only update if the parameters have been tainted
      return false unless params_tainted

      @_value.write call(@_params)
    end
  end
end
