# frozen_string_literal: true

require 'yaml'
require_relative './tree_entry'
require_relative './fixture_location'

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
      # TODO: is there a better way to find out fixtures root directory?
      fixtures_root = ActiveRecord::Tasks::DatabaseTasks.fixtures_path

      while klass < ActiveRecord::Base
        fixture_file = "#{klass.to_s.tableize}.yml"
        path = File.join(fixtures_root, *fixture_file.split('/'))

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
      fixture_path.to_s.sub(%r{^.*/fixtures/}, '').sub('.yml', '')
    end
  end

  class TreeBuilder
    def self.cache
      @cache ||= {}
    end

    def build_dependency_tree(fixture_path, fixture_name)
      TreeEntry.new(
        FixtureLocation.new(fixture_path, fixture_name),
        nested_fixtures_locations(FixtureModel.new(fixture_path).model_class, fixture_name)
      )
    end

    private

    def nested_fixtures_locations(parent_fixture_model_class, parent_fixture_name)
      associations_for_nested_models(parent_fixture_model_class).each_with_object([]) do |association, acc|
        belongs_to_attribute = belongs_to_attribute_for_association(association)
        model_fixtures = self.class.cache[association.class_name] ||= ModelFixtures.load(association.class_name)

        model_fixtures.each do |fixture|
          next if fixture.attributes.fetch(belongs_to_attribute, '').to_s.sub(/ .*/, '') != parent_fixture_name

          next if fixture_already_collected(acc, fixture)

          acc << build_dependency_tree(fixture.path, fixture.name)
        end
      end
    end

    def fixture_already_collected(list, fixture)
      list.find do |tree_entry|
        tree_entry.value.path == fixture.path && tree_entry.value.name == fixture.name
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
end
