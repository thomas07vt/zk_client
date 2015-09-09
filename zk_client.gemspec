# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zk_client/version'

Gem::Specification.new do |spec|
  spec.name          = "zk_client"
  spec.version       = ZkClient::VERSION
  spec.authors       = ["John Thomas"]
  spec.email         = ["john.thomas@autodesk.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://10.40.83.93'
  end

  spec.summary       = "A simple Zookeeper client used in the Mojo framework."
  spec.description   = %q{ This gem allows quick and simple access to a Zookeeper
server.
  }
  spec.homepage      = "https://git.autodesk.com/EIS-EA-MOJO/zk_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.platform      = 'java'
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "zookeeper"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
end

