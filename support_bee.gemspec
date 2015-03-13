# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'support_bee/version'

Gem::Specification.new do |spec|
  spec.name          = "support_bee"
  spec.version       = SupportBee::VERSION
  spec.authors       = ["Ben Reinhart", "Dan Gilbert"]
  spec.email         = ["us@shopstick.com"]
  spec.summary       = %q{SupportBee API wrapper}
  spec.description   = %q{Ruby client for the SupportBee API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
