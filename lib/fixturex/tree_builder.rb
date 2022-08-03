# frozen_string_literal: true

require 'yaml'
require_relative './tree_entry'
require_relative './fixture_location'

module Fixturex
  class Error < StandardError; end

  # Fixtures for model class
  class ModelFixtures
    Fixture = Struct.new(:name, :path, :attributes)

    def self.load(model_class)
      fixtures_paths(model_class).each_with_object([]) do |path, acc|
        fixtures = YAML.load_file(path)
        fixtures.select! do |_name, attributes|
          # if fixture has `type` - STI - then we only want type == class_name
          attributes['type'].nil? || attributes['type'] == model_class.name
        end
        acc.concat(fixtures.map { |name, attributes| Fixture.new(name, path, attributes) })
      end
    end

    def self.fixtures_paths(model_class)
      fixtures_paths = []
      # TODO: is there a better way to find out fixtures root directory?
      fixtures_root = ActiveRecord::Tasks::DatabaseTasks.fixtures_path

      while model_class < ActiveRecord::Base
        fixture_file = "#{model_class.to_s.tableize}.yml"
        path = File.join(fixtures_root, *fixture_file.split('/'))

        fixtures_paths << path if File.exist?(path)

        model_class = model_class.superclass
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

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def nested_fixtures_locations(parent_fixture_model_class, parent_fixture_name)
      associations_for_nested_models(parent_fixture_model_class).each_with_object([]) do |association, acc|
        belongs_to_attribute = belongs_to_attribute_for_association(association)
        child_model_class = association_model_class(association)
        model_fixtures = self.class.cache[association.class_name] ||= ModelFixtures.load(child_model_class)

        model_fixtures.each do |fixture|
          next if fixture.attributes.fetch(belongs_to_attribute, '').to_s.sub(/ .*/, '') != parent_fixture_name

          next if fixture_already_collected(acc, fixture)

          acc << build_dependency_tree(fixture.path, fixture.name)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def association_model_class(association)
      class_name = association.class_name

      unless Object.const_defined?(class_name)
        namespace = association.active_record.name.split('::')[0..-2].join('::')
        class_name = "#{namespace}::#{class_name}"
      end

      class_name.constantize
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
        child_model_class = association_model_class(association)
        child_model_class.reflect_on_all_associations(:belongs_to).find do |belongs_to_association|
          belongs_to_association.class_name == association.active_record.name
        end.name.to_s
      end
    end
  end
end
