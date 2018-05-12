# frozen_string_literal: true

module Vissen
  module Parameterized
    # Simple proxy object for the parameter hash stored in Parameterized
    # objects. It allows access to parameters that looks like `params.input`
    # instead of `params[:input].value`.
    class Accessor
      # @param  parameters [Hash<Symbol, Parameter>] the parameters to provide
      #   access to.
      def initialize(parameters)
        parameters.each do |key, param|
          define_singleton_method(key) { param.value }
        end

        freeze
      end
    end
  end
end
