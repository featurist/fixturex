# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

if ENV.fetch('COVERAGE', false)
  require 'simplecov'
  SimpleCov.start do
    enable_coverage :branch
    add_filter '/spec/'
    add_filter '/dummy/'
    minimum_coverage line: 100, branch: 100
  end
end

require 'bundler/setup'
require 'awesome_print'
require 'fixturex'
require 'json'

require_relative './dummy/config/environment'
require 'rspec/rails'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
