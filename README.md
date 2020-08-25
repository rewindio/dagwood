# 🥪 Dagwood

Dagwood allows you to determine the resolution order of dependencies, using a [topologically sorted directed acyclic graph](https://en.wikipedia.org/wiki/Topological_sorting) (DAG - get it?).

What does this mean? Let's use an example. When making a sandwich, it is important to follow a specific order of operations. We know that the bread needs to be sliced before we can put the mustard on it, just like we know there is no point closing the sandwich before putting the smoked meat in it. By stating all these dependencies (e.g. `add_mustard` depends on `slice_bread`), we can determine the full, correct order in which we should make our sandwich. We call this a `DependencyGraph`.

See the features listed below for ways in which we can use this information.

Other examples where Dagwood might be useful are: scheduling Sidekiq jobs to run in a specific order, determining the order in which software packages must be installed on a server, figuring out how long a project might take based on which steps need to be completed first, and many more.

#### Features:
**Serial ordering of dependencies**

The basic case. Determine the order of dependencies, one item at a time. The `order` method returns an array of dependencies, in the order they need to be resolved.
```ruby
graph = Dagwood::DependencyGraph.new(add_mustard: [:slice_bread], add_smoked_meat: [:slice_bread], close_sandwich: [:add_smoked_meat])
graph.order
=> [:slice_bread, :add_mustard, :add_smoked_meat, :close_sandwich]
```
 
**Parallel ordering of dependencies**

Sometimes certain dependencies can be resolved at the same time. For example, a friend is helping you make your sandwich and you can both complete certain steps at the same time. The `parallel_order` method functions very similarly to `order`, except the items in the array are "groups" of dependencies which can be resolved in parallel (in this example, `add_smoked_meat` and `add_mustard` can be done at the same time).

```ruby
graph = Dagwood::DependencyGraph.new(add_mustard: [:slice_bread], add_smoked_meat: [:slice_bread], close_sandwich: [:add_smoked_meat])
graph.parallel_order
=> [[:slice_bread], [:add_smoked_meat, :add_mustard], [:close_sandwich]]
```

 - Reverse ordering of dependencies
 - Subgraph generation
 - Graph merging


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

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the spec. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/rewindio/dagwood](https://github.com/rewindio/dagwood).
