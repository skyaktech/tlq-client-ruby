# frozen_string_literal: true

require_relative "lib/tlq_client/version"

Gem::Specification.new do |spec|
  spec.name          = "tlq-client"
  spec.version       = TLQClient::VERSION
  spec.authors       = ["Nebojsa Jakovljevic"]
  spec.email         = ["nebojsa@skyak.tech"]

  spec.summary       = "Ruby client for TLQ (Tiny Little Queue)"
  spec.description   = "A Ruby client library to interact with TLQ message queue"
  spec.homepage      = "https://tinylittlequeue.app/"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/skyaktech/tlq-client-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/skyaktech/tlq-client-ruby/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/tlq-client"

  spec.files = Dir.glob(%w[
    lib/**/*
    LICENSE
    README.md
    CHANGELOG.md
  ]).reject { |f| File.directory?(f) }

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "yard", "~> 0.9"
end
