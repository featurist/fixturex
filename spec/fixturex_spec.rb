# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Fixturex do
  it 'returns self' do
    tree = Fixturex::TreeBuilder.new.build_dependency_graph(
      Rails.root.join('test/fixtures/things.yml'),
      'thing_1'
    )

    entry_value = tree.value
    expect(entry_value.path).to eq(Rails.root.join('test/fixtures/things.yml'))
    expect(entry_value.line).to eq(3)
    expect(entry_value.name).to eq('thing_1')
    expect(tree.children).to eq([])
  end

  it 'follows has_many associations' do
    tree = Fixturex::TreeBuilder.new.build_dependency_graph(
      Rails.root.join('test/fixtures/forests.yml'),
      'sherwood'
    )

    expect(JSON.pretty_generate(tree.to_h)).to eq(
      JSON.pretty_generate(
        {
          value: {
            name: 'sherwood',
            path: Rails.root.join('test/fixtures/forests.yml').to_s,
            line: 1
          },
          children: [
            {
              value: {
                name: 'oak',
                path: Rails.root.join('test/fixtures/trees.yml').to_s,
                line: 1
              },
              children: [
                {
                  value: {
                    name: 'leaf_1',
                    path: Rails.root.join('test/fixtures/leaves.yml').to_s,
                    line: 1
                  },
                  children: []
                },
                {
                  value: {
                    name: 'leaf_2',
                    path: Rails.root.join('test/fixtures/leaves.yml').to_s,
                    line: 4
                  },
                  children: []
                },
                {
                  value: {
                    name: 'oak_trunk',
                    path: Rails.root.join('test/fixtures/trunks.yml').to_s,
                    line: 1
                  },
                  children: []
                }
              ]
            },
            {
              value: {
                name: 'pine',
                path: Rails.root.join('test/fixtures/trees.yml').to_s,
                line: 4
              },
              children: [
                {
                  value: {
                    name: 'pine_trunk',
                    path: Rails.root.join('test/fixtures/trunks.yml').to_s,
                    line: 4
                  },
                  children: []
                }
              ]
            }
          ]
        }
      )
    )
  end
end
