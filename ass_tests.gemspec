# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ass_tests/version'

Gem::Specification.new do |spec|
  spec.name          = "ass_tests"
  spec.version       = AssTests::VERSION
  spec.authors       = ["Leonid Vlasov"]
  spec.email         = ["leoniv.vlasov@gmail.com"]

  spec.summary       = %q{Framework for unit testing code written on 1C:Enterprise embedded programming language}
  spec.description   = %q{It make possible to write tests for 1C:Enterprise on Ruby easy. Access to 1C runtime via OLE. Works only in Windows or Cygwin!!!}
  spec.homepage      = "https://github.com/leoniv/ass_tests"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ass_ole"
  spec.add_dependency "ass_maintainer-info_base"
  spec.add_dependency "minitest", "~> 5.10"
  spec.add_dependency "minitest-hooks"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "mocha"
end
