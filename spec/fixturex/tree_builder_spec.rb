# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/fixturex/tree_builder'

RSpec.describe Fixturex::TreeBuilder do
  it 'returns self' do
    tree = Fixturex::TreeBuilder.new.build_dependency_tree(
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
    tree = Fixturex::TreeBuilder.new.build_dependency_tree(
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

  it 'follows polymorphic associations' do
    tree = Fixturex::TreeBuilder.new.build_dependency_tree(
      Rails.root.join('test/fixtures/posts.yml'),
      'post_with_attachment'
    )

    expect(JSON.pretty_generate(tree.children.map(&:to_h))).to eq(
      JSON.pretty_generate(
        [
          {
            value: {
              name: 'post_1_picture_1',
              path: Rails.root.join('test/fixtures/pictures.yml').to_s,
              line: 1
            },
            children: []
          },
          {
            value: {
              name: 'post_1_picture_2',
              path: Rails.root.join('test/fixtures/pictures.yml').to_s,
              line: 4
            },
            children: []
          },
          {
            value: {
              name: 'post_attachment',
              path: Rails.root.join('test/fixtures/attachments.yml').to_s,
              line: 1
            },
            children: []
          }
        ]
      )
    )
  end

  it 'handles belongs_to with custom :class_name' do
    tree = Fixturex::TreeBuilder.new.build_dependency_tree(
      Rails.root.join('test/fixtures/writers.yml'),
      'kevin'
    )

    expect(JSON.pretty_generate(tree.children.map(&:to_h))).to eq(
      JSON.pretty_generate(
        [
          {
            value: {
              name: 'kevins_book',
              path: Rails.root.join('test/fixtures/books.yml').to_s,
              line: 4
            },
            children: []
          }
        ]
      )
    )
  end

  it 'handles namespaced models' do
    tree = Fixturex::TreeBuilder.new.build_dependency_tree(
      Rails.root.join('test/fixtures/customers.yml'),
      'bob'
    )

    expect(JSON.pretty_generate(tree.children.map(&:to_h))).to eq(
      JSON.pretty_generate(
        [
          {
            value: {
              name: 'bobs_finance_order',
              path: Rails.root.join('test/fixtures/finance/orders.yml').to_s,
              line: 2
            },
            children: []
          },
          {
            value: {
              name: 'sub1',
              path: Rails.root.join('test/fixtures/finance/subscriptions.yml').to_s,
              line: 1
            },
            children: [
              {
                value: {
                  name: 'subscription_event_1',
                  path: Rails.root.join('test/fixtures/finance/subscription_events.yml').to_s,
                  line: 1
                },
                children: []
              }
            ]
          }
        ]
      )
    )
  end

  it 'handles STI (fixtures reside in a file named after superclass)' do
    tree = Fixturex::TreeBuilder.new.build_dependency_tree(
      Rails.root.join('test/fixtures/customers.yml'),
      'alice'
    )

    expect(JSON.pretty_generate(tree.children.map(&:to_h))).to eq(
      JSON.pretty_generate(
        [
          {
            value: {
              name: 'alices_shipping_address',
              path: Rails.root.join('test/fixtures/addresses.yml').to_s,
              line: 1
            },
            children: []
          },
          {
            value: {
              name: 'alices_billing_address_2',
              path: Rails.root.join('test/fixtures/billing_addresses.yml').to_s,
              line: 2
            },
            children: []
          },
          {
            value: {
              name: 'alices_billing_address',
              path: Rails.root.join('test/fixtures/addresses.yml').to_s,
              line: 5
            },
            children: []
          }
        ]
      )
    )
  end

  # If a namespaced model `has_many` another model under the same namespace, then Rails association model class
  # contains no namespace, which is wrong and blows up when constantized.
  it 'handles implicit namespace' do
    tree = Fixturex::TreeBuilder.new.build_dependency_tree(
      Rails.root.join('test/fixtures/finance/subscriptions.yml'),
      'sub1'
    )
    expect(JSON.pretty_generate(tree.to_h)).to eq(
      JSON.pretty_generate(
        {
          value: {
            name: 'sub1',
            path: Rails.root.join('test/fixtures/finance/subscriptions.yml').to_s,
            line: 1
          },
          children: [
            {
              value: {
                name: 'subscription_event_1',
                path: Rails.root.join('test/fixtures/finance/subscription_events.yml').to_s,
                line: 1
              },
              children: []
            }
          ]
        }
      )
    )
  end
end
