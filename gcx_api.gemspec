# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gcx_api/version'

Gem::Specification.new do |gem|
  gem.name          = "gcx_api"
  gem.version       = GcxApi::VERSION
  gem.authors       = ["Josh Starcher"]
  gem.email         = ["josh.starcher@gmail.com"]
  gem.description   = %q{Ruby library for the GCX API}
  gem.summary       = %q{Ruby library for the GCX API}
  gem.homepage      = "https://github.com/CruGlobal/gcx_api"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency('rest-client')
  gem.add_dependency('ox')
end
