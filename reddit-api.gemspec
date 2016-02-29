# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reddit/api/version'

Gem::Specification.new do |spec|
  spec.name          = "reddit-api"
  spec.version       = Reddit::Api::VERSION
  spec.authors       = ["="]
  spec.email         = ["="]

  spec.summary       = "A interface to the reddit API. A clean and simple aproach. Get prying!"
  spec.description   = ""
  spec.homepage      = "https://github.com/karl-b/reddit-api"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "rest-client", "~> 1.0"
  spec.add_runtime_dependency "log4r"
  spec.add_runtime_dependency "pry"
end
