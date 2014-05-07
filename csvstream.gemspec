# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csvstream/version'

Gem::Specification.new do |spec|
  spec.name          = "csvstream"
  spec.version       = CSVStream::VERSION
  spec.authors       = ["Adam DerMarderosian"]
  spec.email         = ["adam@ourstage.com"]
  spec.description   = %q{A more robust and featured parser than contained in Ruby}
  spec.summary       = %q{A CSV Parsing gem}
  spec.homepage      = "https://github.com/adermard/CSVStream"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
