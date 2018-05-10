
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vissen/parameterized/version'

Gem::Specification.new do |spec|
  spec.name          = 'vissen-parameterized'
  spec.version       = Vissen::Parameterized::VERSION
  spec.authors       = ['Sebastian Lindberg']
  spec.email         = ['seb.lindberg@gmail.com']

  spec.summary       = 'Parameterized creates a dependency graph for pure ' \
                       'functions.'
  spec.description   = ''
  spec.homepage      = 'https://github.com/midi-visualizer/vissen-parameterized'
  spec.license       = 'MIT'

  spec.metadata['yard.run'] = 'yri'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
