# frozen_string_literal: true

require_relative "lib/tlq_client/version"

Gem::Specification.new do |spec|
  spec.name          = "tlq-client"
  spec.version       = TLQClient::VERSION
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

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ features/ .git .github vendor/])
    end
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
