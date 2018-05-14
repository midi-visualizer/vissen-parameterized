# frozen_string_literal: true

module Vissen
  module Parameterized
    # The scope exists to protect parameterized objects from being bound to
    # parameters with a different lifetime than their own.
    #
    # Each scope is bound to a `Conditional` and as long as it, as well as the
    # conditionals of all the parents return false, the scope is considered to
    # be alive.
    #
    # By checking that one scope is included in another, it is possible to
    # guarantee that values belonging to the first scope are safe to use.
    class Scope
      # @return [Scope] the parent of this scope.
      attr_reader :parent

      # A scope is considered dead once its conditional returns true, or if the
      # parent scope is also dead.
      #
      # @return [true] if the conditional is met.
      # @return [false] otherwise.
      def dead?
        @conditional.met? || parent.dead?
      end

      # The inverse of `#dead?`
      #
      # @see dead?
      #
      # @return [false] if the conditional is met.
      # @return [true] otherwise.
      def alive?
        !dead?
      end

      # Checks if the given object is included, either in this scope or in any
      # of the parent scopes.
      #
      # @param  obj [#scope] the object to scope check.
      # @return [true] if the object either shares this scope or a parent scope.
      # @reutrn [false] otherwise.
      def include?(obj)
        include_scope? obj.scope
      end

      alias === include?

      # Creates a new scope that is a direct descendent of this one.
      #
      # @param  conditional [Conditional] the conditional to use for the new
      #   scope.
      # @return [Scope] a new child scope.
      def create_scope(conditional)
        Scope.new self, conditional
      end

      # Checks if the given scope is included in the scope hierarchy of this
      # one.
      #
      # @param  [Scope, Object] the scope to check.
      # @return [true] if the given scope is equal to this one, or one of the
      #   parents.
      def include_scope?(other)
        equal?(other) || @parent.include_scope?(other)
      end

      protected

      # Creates a new scope. This method is protected to avoid erroneous parent
      # structures and new top level scopes should instead be created using
      # `GlobalScope.instance.create_scope`.
      #
      # @raise  [TypeError] if the conditional does not respond to `#met?`.
      # @raise  [RuntimeError] if the conditional is out of scope.
      def initialize(parent, conditional)
        raise TypeError unless conditional.respond_to? :met?
        @parent = parent

        raise 'conditional is outside this scope' unless include? conditional
        @conditional = conditional
      end
    end
  end
end
