# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Fixturex do
  it 'works' do
    tree = Fixturex::TreeBuilder.new.build_dependency_graph('users', 'bob')

    entry_value = tree.value
    expect(entry_value.path).to eq(Rails.root.join('test/fixtures/users.yml').to_s)
    expect(entry_value.line_number).to eq(3)
    expect(tree.children).to eq([])
  end
end
