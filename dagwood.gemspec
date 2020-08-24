# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dagwood/version'

Gem::Specification.new do |spec|
  spec.name          = 'dagwood'
  spec.version       = Dagwood::VERSION
  spec.authors       = ['Rewind.io']
  spec.email         = ['team@rewind.io']

  spec.summary       = 'For all your dependency graph needs'
  spec.description   = 'Dagwood allows you to create dependency graphs for doing work in series or in parallel, always in the right order.'
  spec.homepage      = 'https://github.com/rewindio/dagwood'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|.github|examples)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '2.0.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rewind-ruby-style'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'rubocop', '~> 0.87.0'
  spec.add_development_dependency 'simplecov', '~> 0.19'
  spec.add_development_dependency 'simplecov-console', '~> 0.4'
end
