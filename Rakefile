# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/unit_test.rb"]
end

desc "Run integration tests (requires running TLQ server)"
task :integration do
  ruby "test/integration_test.rb"
end

desc "Run all tests (unit + integration)"
task :test_all => [:test, :integration]

task default: :test
