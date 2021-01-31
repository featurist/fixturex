# frozen_string_literal: true

require 'yaml'
require 'fixturex/version'

module Fixturex
  class Error < StandardError; end

  class TreeBuilder
    def initialize(fixtures_root = Rails.root.join('test', 'fixtures'))
      @fixtures_root = fixtures_root
    end

    def build_dependency_graph(fixture_set, fixture_name)
      value = Fixture.new(fixture_set, fixture_name, @fixtures_root)
      TreeEntry.new(value, [])
    end
  end

  TreeEntry = Struct.new(:value, :children)

  Fixture = Struct.new(:fixture_set, :fixture_name, :fixtures_root) do
    def path
      File.join(fixtures_root, "#{fixture_set}.yml")
    end

    def line_number
      File.readlines(path).each_with_index do |line, index|
        return index + 1 if line.match?(/^#{fixture_name}:/)
      end

      raise "Couldn't fine line number for '#{path}:#{fixture_name}'"
    end
  end
end
