# frozen_string_literal: true

module Vissen
  module Parameterized
    # The global scope is by definition a singleton and exists as the top level
    # parent of all other scopes.
    class GlobalScope < Scope
      include Singleton

      # The global scope can never die.
      #
      # @return [false]
      def dead?
        false
      end

      # @see dead?
      #
      # @return [true]
      def alive?
        true
      end

      # @raise [RuntimeError]
      def kill!
        raise 'The global scope cannot be killed'
      end

      # The only scope that is included in the global scope is the global scope
      # itself.
      #
      # @param  scope [Object] the scope to check.
      # @return [true] if the given scope is the global scope.
      # @return [false] otherwise.
      def include_scope?(scope)
        equal?(scope)
      end

      # @raise [StopIteration]
      def parent
        raise StopIteration
      end

      private

      def initialize; end
    end
  end
end
