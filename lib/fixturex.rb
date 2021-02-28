# frozen_string_literal: true

require 'yaml'
require 'fixturex/version'

module Fixturex
  class Error < StandardError; end

  # Fixtures for model class
  class ModelFixtures
    Fixture = Struct.new(:name, :path, :attributes)

    def self.load(class_name)
      fixtures_paths(class_name).each_with_object([]) do |path, acc|
        fixtures = YAML.load_file(path)
        fixtures.select! do |_name, attributes|
          # if fixture has `type` - STI - then we only want type == class_name
          attributes['type'].nil? || attributes['type'] == class_name
        end
        acc.concat(fixtures.map { |name, attributes| Fixture.new(name, path, attributes) })
      end
    end

    def self.fixtures_paths(class_name)
      fixtures_paths = []
      klass = class_name.constantize

      while klass < ActiveRecord::Base
        fixture_file = "#{klass.to_s.tableize}.yml"
        path = Rails.root.join('test', 'fixtures', *fixture_file.split('/'))

        fixtures_paths << path if File.exist?(path)

        klass = klass.superclass
      end
      fixtures_paths
    end
  end

  FixtureModel = Struct.new(:fixture_path) do
    def model_class
      # TODO: support custom model_class from yaml
      # TODO: support (or document the limitation) `set_fixture_class my_products: Product`
      ActiveRecord::FixtureSet.default_fixture_model_name(fixture_set).constantize
    end

    private

    def fixture_set
      # TODO: work out fixture root
      fixture_path.to_s.sub(Rails.root.join('test', 'fixtures').to_s, '')[1..].sub('.yml', '')
    end
  end

  class TreeBuilder
    def build_dependency_graph(fixture_path, fixture_name)
      TreeEntry.new(
        FixtureLocation.new(fixture_path, fixture_name),
        nested_fixtures_locations(FixtureModel.new(fixture_path).model_class, fixture_name)
      )
    end

    private

    def nested_fixtures_locations(parent_fixture_model_class, parent_fixture_name)
      associations_for_nested_models(parent_fixture_model_class).each_with_object([]) do |association, acc|
        belongs_to_attribute = belongs_to_attribute_for_association(association)
        model_fixtures = ModelFixtures.load(association.class_name)

        model_fixtures.each do |fixture|
          next if fixture.attributes.fetch(belongs_to_attribute, '').to_s.sub(/ .*/, '') != parent_fixture_name

          acc << build_dependency_graph(fixture.path, fixture.name)
        end
      end
    end

    def associations_for_nested_models(model_class)
      model_class.reflect_on_all_associations(:has_many) +
        model_class.reflect_on_all_associations(:has_one)
    end

    def belongs_to_attribute_for_association(association)
      if association.type.present?
        association.type.sub('_type', '')
      else
        association.active_record.name.tableize.singularize
      end
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

  FixtureLocation = Struct.new(:path, :name) do
    def line
      File.readlines(path).each_with_index do |line, index|
        return index + 1 if line.match?(/^#{name}:/)
      end

      raise "Couldn't fine line number for '#{path}:#{name}'"
    end

    def to_h
      {
        name: name,
        path: path.to_s,
        line: line
      }
    end
  end
end
