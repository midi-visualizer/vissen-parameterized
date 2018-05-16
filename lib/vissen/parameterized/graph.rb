# frozen_string_literal: true

module Vissen
  module Parameterized
    # The graph implements a mechanism for updating and untainting a set of
    # interconnected paramaeterized objects.
    class Graph
      # @raise  [ScopeError] if any of the end nodes are not included in the
      #   scope.
      #
      # @param  end_nodes [Array<Parameterized>] the top level parameterized
      #   objects.
      # @param  scope [Scope] the scope in which the graph (and the end nodes)
      #   exists.
      def initialize(end_nodes, scope: GlobalScope.instance)
        end_nodes.each do |node|
          raise ScopeError unless scope.include? node
        end

        @end_nodes = end_nodes

        freeze
      end

      # Updates the entire graph.
      def update!
        @end_nodes.each(&:tainted?)
        @end_nodes.each(&:untaint!)

        @end_nodes.each { |node| yield node.value } if block_given?
      end
    end
  end
end
