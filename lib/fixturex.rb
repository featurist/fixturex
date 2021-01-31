require 'ostruct'
require 'fixturex/version'

module Fixturex
  class Error < StandardError; end

  class TreeEntry < Struct.new(:value, :children)
    def to_h
      {
        value: value.to_h,
        children: children.map(&:to_h)
      }
    end
  end

  class EntryValue < OpenStruct; end

  def self.build_dependency_graph(fixture_type, fixture_name)
    value = EntryValue.new(
      fixture_name: fixture_name,
      fixture_type: fixture_type,
      file_path: 'test/fixtures/users.yml',
      line: 3
    )
    TreeEntry.new(value, [])
  end
end
