# frozen_string_literal: true

require 'optparse'
require_relative '../lib/fixturex/tree_builder'
require 'active_record/fixtures'

options = {}
OptionParser.new do |opts|
  opts.on('-j', '--json', 'output json instead of vimgrep')
end.parse!(into: options)

if ARGV.size != 2
  puts 'Usage: bundle exec fixturex FIXTURE_PATH FIXTURE_NAME [options]'
  exit 1
end

tree = Fixturex::TreeBuilder.new.build_dependency_tree(ARGV[0], ARGV[1])

if options[:json]
  require 'json'
  puts JSON.generate(tree.to_h)
else
  require_relative '../lib/fixturex/vimgrep_tree_formatter'
  Fixturex::VimgrepTreeFormatter.new(tree).print
end
