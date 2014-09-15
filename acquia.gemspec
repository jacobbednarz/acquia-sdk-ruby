lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acquia/version'

Gem::Specification.new do |spec|
  spec.name          = 'acquia'
  spec.version       = Acquia::VERSION
  spec.authors       = ['Jacob Bednarz']
  spec.email         = ['jacob.bednarz@gmail.com']
  spec.summary       = 'Acquia Ruby SDK'
  spec.description   = 'A Ruby based SDK for interacting with the Acquia Hosting platform'
  spec.homepage      = 'http://github.com/jacobbednarz/acquia-sdk-ruby'
  spec.license       = 'MIT'

  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'byebug', '~> 2.7.0'
end
