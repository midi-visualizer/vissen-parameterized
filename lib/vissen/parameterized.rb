# frozen_string_literal: true

require 'forwardable'

require 'vissen/parameterized/version'
require 'vissen/parameterized/accessor'
require 'vissen/parameterized/value'
require 'vissen/parameterized/value/bool'
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

    def_delegator :@_value, :is_a?, :returns_a?

    private_constant :Accessor

    # Forwards all parameters to super.
    #
    # @param  args [Array<Object>] the arguments to forward to super.
    # @param  parameters [Hash<Symbol, Parameter>] the input parameters.
    # @param  output [Value] the output value object.
    def initialize(*args, parameters:, output:, scope: nil)
      super(*args)

      @_visited  = false
      @_params   = parameters
      @_value    = output
      @_accessor = Accessor.new parameters
      @_scope    = scope
    end

    # @raise  [NotImplementedError] if not implemented by descendent.
    #
    # @param  _parameters [Accessor] the parameters of the parameterized object.
    # @return [Object] an object compatible with the output value type should be
    #   returned.
    def call(_parameters)
      raise NotImplementedError
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

      @_value.write call(@_accessor)
    end

    # Binds a parameter to a target value.
    #
    # @see    Parameter#bind
    # @raise  [KeyError] if the parameter is not found.
    #
    # @param  param [Symbol] the parameter to bind.
    # @param  target [#value] the value object to bind to.
    # @return [Parameter] the parameter that was bound.
    def bind(param, target)
      # TODO: Only allow binding to target from the same scope,
      #       or from the global scope.
      @_params.fetch(param).bind target
    end

    # @return [Accessor] a proxy object that provides access to parameters via
    #   method calls instead of hash lookups.
    def parameters
      @_accessor
    end

    alias params parameters
  end
end

require 'vissen/parameterized/conditional'
