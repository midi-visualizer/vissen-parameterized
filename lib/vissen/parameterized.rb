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
  module Parameterized
    extend Forwardable

    def_delegators :@_value, :value

    # Forwards all parameters to super.
    def initialize(*)
      super

      @_visited = false
    end

    # @raise  [NotImplementedError] if not implemented by descendent.
    #
    # @param  _parameters [Hash] the parameters of the parameterized object.
    # @return [Object] an object compatible with the output value type should be
    #   returned.
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

    # Marks the output value and all input parameters as untainted.
    #
    # @return [false]
    def untaint!
      @_visited = false
      # ASUMPTION: if the value is untainted the params must also be unchanged.
      return unless @_value.tainted?

      @_params.each { |_, param| param.untaint! }
      @_value.untaint!
    end

    # Checks if the output value of the parameterized object has changed. If any
    # of the input parameters have changed since last calling `#untaint!` the
    # `#call` method will be evaluated in order to determine the state of the
    # output value.
    #
    # Note that `#call` is only evaluated once after the object has been
    # untainted. Subsequent calls to `#tainted?` will refer to the result of the
    # first operation.
    #
    # @return [true] if the output value has changed since last calling
    #   `#untaint!`.
    # @return [false] otherwise.
    def tainted?
      return @_value.tainted? if @_visited
      @_visited = true

      params_tainted =
        @_params.reduce(false) do |a, (_, param)|
          param.tainted? || a
        end

      return false unless params_tainted

      @_value.write call(@_params)
    end
  end
end
