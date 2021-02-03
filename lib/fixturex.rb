# frozen_string_literal: true

require 'yaml'
require 'fixturex/version'

module Fixturex
  class Error < StandardError; end

  class TreeBuilder
    def build_dependency_graph(fixture_path, fixture_name)
      fixture = Fixture.new(fixture_path, fixture_name)
      TreeEntry.new(fixture, nested_fixtures(fixture))
    end

    private

    def nested_fixtures(fixture)
      fixture.model_class.reflect_on_all_associations(:has_many).each_with_object([]) do |association, acc|
        association_fixture_set = fixture_set_for_association(association)
        association_fixture_path = path_for_fixture_set(association_fixture_set)
        association_fixtures = load_fixture_file(association_fixture_set)

        belongs_to_attribute = belongs_to_attribute_for_association(association)

        association_fixtures.select! do |_, attributes|
          attributes.fetch(belongs_to_attribute, '').to_s.sub(/ .*/, '') == fixture.name
        end

        association_fixtures.each do |fixture_name, _|
          acc << build_dependency_graph(association_fixture_path, fixture_name)
        end
      end
    end

    def belongs_to_attribute_for_association(association)
      if association.type.present?
        association.type.sub('_type', '')
      else
        association.active_record.name.tableize.singularize
      end
    end

    def load_fixture_file(fixture_set)
      return {} unless File.exist?((path = path_for_fixture_set(fixture_set)))

      YAML.load_file(path)
    end

    def path_for_fixture_set(fixture_set)
      fixture_file = "#{fixture_set}.yml"
      Rails.root.join('test', 'fixtures', *fixture_file.split('/'))
    end

    # TODO: support custom model_class (specified in yml)
    def fixture_set_for_association(association)
      association.class_name.tableize
    end
  end

  TreeEntry = Struct.new(:value, :children) do
    def to_h
      {
        value: value.to_h,
        children: children.map(&:to_h)
      }
    end
  end

  Fixture = Struct.new(:path, :name) do
    def line
      File.readlines(path).each_with_index do |line, index|
        return index + 1 if line.match?(/^#{name}:/)
      end

      raise "Couldn't fine line number for '#{path}:#{name}'"
    end

    def model_class
      ActiveRecord::FixtureSet.default_fixture_model_name(fixture_set).constantize
    end

    def to_h
      {
        name: name,
        path: path.to_s,
        line: line
      }
    end

    private

    def fixture_set
      # TODO: work out fixture root
      path.to_s.sub(Rails.root.join('test', 'fixtures').to_s, '')[1..].sub('.yml', '')
    end
  end
end
