# frozen_string_literal: true

require 'ostruct'
require 'spec_helper'
require_relative '../../lib/fixturex/vimgrep_tree_formatter'
require_relative '../../lib/fixturex/fixture_location'

RSpec.describe Fixturex::VimgrepTreeFormatter do
  it 'prints tree with a single element' do
    stdout = double('stdout')
    tree = OpenStruct.new(
      value: Fixturex::FixtureLocation.new('some', 'thing', 1),
      children: []
    )
    formatter = Fixturex::VimgrepTreeFormatter.new(tree, stdout)
    expect(stdout).to receive(:puts).with('some:1:1    thing')

    formatter.print
  end

  it 'prints tree in a format, suitable for vim quickfix/location list' do
    stdout = double('stdout')
    tree = OpenStruct.new(
      value: Fixturex::FixtureLocation.new('some', 'thing', 1),
      children: [
        OpenStruct.new(
          value: Fixturex::FixtureLocation.new('some_child', 'thing', 2),
          children: [
            OpenStruct.new(
              value: Fixturex::FixtureLocation.new('some_child_child', 'thing', 5),
              children: []
            )
          ]
        ),
        OpenStruct.new(
          value: Fixturex::FixtureLocation.new('some_other_child', 'thing', 5),
          children: []
        )
      ]
    )
    formatter = Fixturex::VimgrepTreeFormatter.new(tree, stdout)
    expect(stdout).to receive(:puts).with('some:1:1                thing')
    expect(stdout).to receive(:puts).with('some_child:2:1            thing')
    expect(stdout).to receive(:puts).with('some_child_child:5:1        thing')
    expect(stdout).to receive(:puts).with('some_other_child:5:1      thing')

    formatter.print
  end
end
