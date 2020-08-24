# frozen_string_literal: true

require 'tsort'

module Dagwood
  class DependencyGraph
    include TSort

    attr_reader :dependencies

    # @param dependencies [Hash]
    #   A hash of the form { item1: ['item2', 'item3'], item2: ['item3'], item3: []}
    #   would mean that "item1" depends on item2 and item3, item2 depends on item3
    #   and item3 has no dependencies. Nil and missing values will be converted to [].
    def initialize(dependencies)
      @dependencies = Hash.new([]).merge(dependencies.transform_values { |v| v.nil? ? [] : v.sort })
    end

    def order
      @order ||= tsort
    end

    def reverse_order
      @reverse_order ||= order.reverse
    end

    # Similar to #order, except this will group items that
    # have the same "priority", thus indicating they can be done
    # in parallel.
    #
    # Same priority means:
    #  1) They have the same exact same sub-dependencies OR
    #  2) B comes after A and all of B's dependencies have been resolved before A
    def parallel_order
      groups = []
      ungrouped_dependencies = order.dup

      until ungrouped_dependencies.empty?
        # Start this group with the first dependency we haven't grouped yet
        group_starter = ungrouped_dependencies.delete_at(0)
        group = [group_starter]

        ungrouped_dependencies.each do |ungrouped_dependency|
          same_priority = @dependencies[ungrouped_dependency].all? do |sub_dependency|
            groups.reduce(false) { |found, g| found || g.include?(sub_dependency) }
          end

          group << ungrouped_dependency if same_priority
        end

        # Remove depedencies we managed to group
        ungrouped_dependencies -= group

        groups << group.sort
      end

      groups
    end

    # Generate a subgraph starting at the given node
    def subgraph(node)
      return self.class.new({}) unless @dependencies.key? node

      # Add the given node and its dependencies to our hash
      hash = {}
      hash[node] = @dependencies[node]

      # For every dependency of the given node, recursively create a subgraph and merge it into our result
      @dependencies[node].each { |dep| hash.merge! subgraph(dep).dependencies }

      self.class.new hash
    end

    # Returns a new graph containing all dependencies from this graph and the given graph.
    # If both graphs depend on the same item, but that item's sub-dependencies differ, the
    # resulting graph will depend on the union of both.
    def merge(other)
      all_dependencies = {}

      (dependencies.keys | other.dependencies.keys).each do |key|
        all_dependencies[key] = dependencies[key] | other.dependencies[key]
      end

      self.class.new all_dependencies
    end

    private

    def tsort_each_child(node, &block)
      @dependencies.fetch(node, []).each(&block)
    end

    def tsort_each_node(&block)
      @dependencies.each_key(&block)
    end
  end
end
