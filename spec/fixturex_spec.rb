require 'spec_helper'

RSpec.describe Fixturex do
  it 'works' do
    tree = Fixturex.build_dependency_graph('users', 'bob')

    puts tree.to_h
    expect(tree.to_h).to eq({
      value: {
        fixture_type: 'users',
        fixture_name: 'bob',
        file_path: 'test/fixtures/users.yml',
        line: 3
      },
      children: []
    })
  end
end
