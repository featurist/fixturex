# frozen_string_literal: true

module Fixturex
  class VimgrepTreeFormatter
    def initialize(tree, stdout = $stdout)
      @tree = tree
      @stdout = stdout
    end

    def print
      print_entry(@tree, '', file_address_lengths(@tree).max)
    end

    private

    def print_entry(entry, indent, file_address_column_size)
      offset = file_address_column_size - file_address(entry).size

      @stdout.puts "#{file_address(entry)}#{Array.new(offset).map { ' ' }.join}    #{indent}#{entry.value.name}"
      entry.children.each do |child_entry|
        print_entry(child_entry, "#{indent}  ", file_address_column_size)
      end
    end

    def file_address_lengths(entry)
      [
        file_address(entry).size
      ].concat(
        entry.children.map { |e| file_address_lengths(e) }
      ).flatten
    end

    def file_address(entry)
      "#{entry.value.path}:#{entry.value.line}:1"
    end
  end
end
