# coding: utf-8
lib = File.expand_path( '../lib', __FILE__ )
$LOAD_PATH.unshift( lib ) unless $LOAD_PATH.include?( lib )
require 'lastpass-api/version'

Gem::Specification.new do |spec|
  spec.name          = 'lastpass-api'
  spec.version       = Lastpass::VERSION
  spec.authors       = ['Eric Terry']
  spec.email         = ['eterry1388@aol.com']

  spec.summary       = 'Read/Write access to the online LastPass vault using LastPass CLI'
  spec.description   = 'Full access to the LastPass vault to create, read, and update account information and credentials.'
  spec.homepage      = 'http://www.entretechno.com'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split( "\x0" ).reject do |file|
    file.match( %r{^(test|spec|features)/} )
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep( %r{^exe/} ) { |file| File.basename( file ) }
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.0'
  spec.add_development_dependency 'byebug'
end
