# frozen_string_literal: true

require 'spec_helper'

describe Dagwood::DependencyGraph do
  describe '#initialize' do
    it 'converts nil values to []' do
      graph = Dagwood::DependencyGraph.new(item1: nil, item2: [], item3: [:item1])
      expect(graph.dependencies).to eql item1: [], item2: [], item3: [:item1]
    end

    it 'converts missing values to []' do
      graph = Dagwood::DependencyGraph.new(item1: nil)
      expect(graph.dependencies[:item4]).to eql []
    end

    it 'sorts all sub-dependency lists' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item2 item1], item2: %i[item3 item2 item4])
      expect(graph.dependencies).to eql item1: %i[item1 item2], item2: %i[item2 item3 item4]
    end

    it 'works on frozen hashes' do
      graph = Dagwood::DependencyGraph.new({ item1: nil, item2: %i[item3 item2 item4] }.freeze)
      expect(graph.dependencies[:item4]).to eql []
    end
  end

  describe '#order' do
    it 'returns the dependencies in order of least dependent to most dependent' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item2 item3], item2: %i[item3], item3: [])
      expect(graph.order).to eql %i[item3 item2 item1]
    end

    it 'survives missing dependencies' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item2 item3], item2: %i[item3])
      expect(graph.order).to eql %i[item3 item2 item1]

      graph = Dagwood::DependencyGraph.new(item1: %i[item2 item3], item2: %i[item3], item3: nil)
      expect(graph.order).to eql %i[item3 item2 item1]
    end
  end

  describe '#reverse_order' do
    it 'returns the dependencies in order of most dependent to least dependent' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item2 item3], item2: %i[item3], item3: [])
      expect(graph.reverse_order).to eql %i[item1 item2 item3]
    end
  end

  describe '#parallel_order' do
    it 'groups items with no dependencies' do
      graph = Dagwood::DependencyGraph.new(item1: %i[], item2: %i[], item3: %i[])
      expect(graph.parallel_order).to eql [%i[item1 item2 item3]]
    end

    it 'groups items with the exact same dependencies' do
      # Relatively well ordered dependency graph
      graph = Dagwood::DependencyGraph.new(item1: %i[item3], item2: %i[item3], item3: %i[item4 item5], item4: %i[item5], item5: %i[])
      expect(graph.parallel_order).to eql [%i[item5], %i[item4], %i[item3], %i[item1 item2]]

      # Disordered dependency graph
      graph = Dagwood::DependencyGraph.new(item1: %i[], item2: %i[item1], item3: %i[], item4: %i[item3 item5], item5: %i[item3 item6], item6: %i[item1])
      expect(graph.parallel_order).to eql [%i[item1 item3], %i[item2 item6], %i[item5], %i[item4]]
    end

    it 'groups items with the exact same dependencies even if in a different order' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item3 item4], item2: %i[item4 item3])
      expect(graph.parallel_order).to eql [%i[item3 item4], %i[item1 item2]]
    end

    it 'groups items A and B if all of B\'s dependencies have been resolved already' do
      # We know that we can get away with grouping [item1, item2]
      # because item2's dependencies were resolved earlier in the order.
      graph = Dagwood::DependencyGraph.new(item1: %i[item3], item2: %i[item3 item4], item3: %i[item4], item4: %i[])
      expect(graph.parallel_order).to eql [%i[item4], %i[item3], %i[item1 item2]]
    end
  end

  describe '#subgraph' do
    it 'includes only given node if it has no dependencies' do
      graph = Dagwood::DependencyGraph.new(item1: %i[])
      expect(graph.subgraph(:item1).dependencies).to eql item1: %i[]
    end

    it 'returns an empty graph if given node does not exist' do
      graph = Dagwood::DependencyGraph.new(item1: %i[])
      expect(graph.subgraph(:item2).dependencies).to be_empty
    end

    it 'includes all dependencies of the given node as well as their dependencies' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item3], item2: %i[item3 item4], item3: %i[item4], item4: %i[])
      expect(graph.subgraph(:item2).dependencies).to eql item2: %i[item3 item4], item3: %i[item4], item4: %i[]

      graph = Dagwood::DependencyGraph.new(item1: %i[item2 item3 item4], item2: %i[item5 item6 item7], item3: %i[item7 item8 item9])
      expect(graph.subgraph(:item2).dependencies).to eql item2: %i[item5 item6 item7]

      graph = Dagwood::DependencyGraph.new(item1: %i[item2 item3 item4], item2: %i[item5 item6 item7], item3: %i[item7 item8 item9], item5: %i[item3])
      expect(graph.subgraph(:item2).dependencies).to eql item2: %i[item5 item6 item7], item3: %i[item7 item8 item9], item5: %i[item3]
    end
  end

  describe '#merge' do
    it 'returns a new graph with all dependencies from both graphs' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item2])
      other = Dagwood::DependencyGraph.new(item3: %i[item4])

      merged = graph.merge other

      expect(merged.dependencies).to contain_exactly([:item1, %i[item2]], [:item3, %i[item4]])
    end

    it 'works with empty graphs' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item2])
      other = Dagwood::DependencyGraph.new({})

      merged = graph.merge other

      expect(merged.dependencies).to contain_exactly([:item1, %i[item2]])
    end

    it 'merges duplicate dependencies' do
      graph = Dagwood::DependencyGraph.new(item1: %i[item2 item3])
      other = Dagwood::DependencyGraph.new(item1: %i[item2])
      merged = graph.merge other

      expect(merged.dependencies).to contain_exactly([:item1, %i[item2 item3]])

      graph = Dagwood::DependencyGraph.new(item1: %i[item2])
      other = Dagwood::DependencyGraph.new(item1: %i[item2 item3])
      merged = graph.merge other

      expect(merged.dependencies).to contain_exactly([:item1, %i[item2 item3]])

      graph = Dagwood::DependencyGraph.new(item1: %i[item2])
      other = Dagwood::DependencyGraph.new(item1: %i[item2])
      merged = graph.merge other

      expect(merged.dependencies).to contain_exactly([:item1, %i[item2]])
    end
  end
end
