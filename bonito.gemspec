# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bonito/version'

Gem::Specification.new do |spec|
  spec.name          = 'bonito'
  spec.version       = Bonito::VERSION
  spec.authors       = ['Tom Finill']
  spec.email         = ['tomfinill@gmail.com']

  spec.summary       = 'A simple tool to create demo data'
  spec.description   = 'Create realistic demo data by simulating events occurring over some time period'
  spec.homepage      = 'https://github.com/tmfnll/bonito'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'algorithms', '~> 0.5'
  spec.add_dependency 'ruby-progressbar'
  spec.add_dependency 'timecop'

  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'faker', '~> 2.18.0'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'

end
