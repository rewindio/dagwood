# 🥪 Dagwood

Dagwood allows you to determine the resolution order of dependencies, using a [topologically sorted directed acyclic graph](https://en.wikipedia.org/wiki/Topological_sorting) (DAG - get it?).

What does this mean? Let's use an example. When making a sandwich, it is important to follow a specific order of operations. We know that the bread needs to be sliced before we can put the mustard on it, just like we know there is no point closing the sandwich before putting the smoked meat in it. By stating all these dependencies (e.g. `add_mustard` depends on `slice_bread`), we can determine the full, correct order in which we should make our sandwich. We call this a `DependencyGraph`.

See the features listed below for ways in which we can use this information.

Dagwood might be useful for scheduling Sidekiq jobs to run in a specific order, determining the order in which software packages must be installed on a server, figuring out how long a project might take based on which steps need to be completed first, and many more use cases.

#### Features:
**Serial ordering of dependencies**

The basic case. Determine the order of dependencies, one item at a time. The `order` method returns an array of dependencies, in the order they need to be resolved.
```ruby
graph = Dagwood::DependencyGraph.new(add_mustard: [:slice_bread], add_smoked_meat: [:slice_bread], close_sandwich: [:add_mustard, :add_smoked_meat])
graph.order
=> [:slice_bread, :add_mustard, :add_smoked_meat, :close_sandwich]
```

**Parallel ordering of dependencies**

Sometimes certain dependencies can be resolved at the same time. For example, a friend is helping you make your sandwich and you can both complete certain steps at the same time. The `parallel_order` method functions very similarly to `order`, except the items in the array are "groups" of dependencies which can be resolved in parallel (in this example, `add_smoked_meat` and `add_mustard` can be done at the same time).

```ruby
graph = Dagwood::DependencyGraph.new(add_mustard: [:slice_bread], add_smoked_meat: [:slice_bread], close_sandwich: [:add_mustard, :add_smoked_meat])
graph.parallel_order
=> [[:slice_bread], [:add_mustard, :add_smoked_meat], [:close_sandwich]]
```

**Reverse ordering of dependencies**

The `reverse_order` method can be useful in cases where you'd like to apply the opposite order of operations.

```ruby
graph = Dagwood::DependencyGraph.new(add_mustard: [:slice_bread], add_smoked_meat: [:slice_bread], close_sandwich: [:add_mustard, :add_smoked_meat])
graph.reverse_order
=> [:close_sandwich, :add_smoked_meat, :add_mustard, :slice_bread]
```

**Subgraphs**

Perhaps you only care about what is needed to perform the `add_mustard` operation. The `subgraph` method allows you to grab a slice of the DependencyGraph, based on the given node.


```ruby
graph = Dagwood::DependencyGraph.new(add_mustard: [:slice_bread], add_smoked_meat: [:slice_bread], close_sandwich: [:add_mustard, :add_smoked_meat])
subgraph = graph.subgraph :add_mustard
subgraph.order
=> [:slice_bread, :add_mustard]
```

**Graph merging**

The `merge` method allows you to take two DependencyGraphs and merge them. If your two most beloved restaurants have really good sandwich recipes, perhaps you'd like to attempt creating the Ultimate Sandwich by combining the steps for making both?

```ruby
recipe1 = Dagwood::DependencyGraph.new(add_mustard: [:slice_bread], add_smoked_meat: [:slice_bread], close_sandwich: [:add_mustard, :add_smoked_meat])
recipe2 = Dagwood::DependencyGraph.new(add_mayo: [:slice_bread], add_turkey: [:slice_bread], close_sandwich: [:add_mayo, :add_turkey, :add_pickles])

ultimate_recipe = recipe1.merge(recipe2)
ultimate_recipe.order
=> [:slice_bread, :add_mustard, :add_smoked_meat, :add_mayo, :add_pickles, :add_turkey, :close_sandwich]
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dagwood'
```

or this line to your gem's gemspec:

```ruby
spec.add_dependency 'dagwood'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dagwood


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the spec. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/rewindio/dagwood](https://github.com/rewindio/dagwood).
