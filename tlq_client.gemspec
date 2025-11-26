# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "tlq-client"
  spec.version       = "0.1.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]
  
  spec.summary       = "Ruby client for TLQ (Tiny Little Queue)"
  spec.description   = "A Ruby client library to interact with TLQ message queue"
  spec.homepage      = "https://github.com/yourusername/tlq-client-ruby"
  spec.license       = "MIT"
  
  spec.required_ruby_version = ">= 2.6.0"
  
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yourusername/tlq-client-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/yourusername/tlq-client-ruby/blob/main/CHANGELOG.md"
  
  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency "json", "~> 2.0"
  spec.add_dependency "uuid", "~> 2.3"
  
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end

