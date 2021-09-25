module Fixturex
  class FixtureLocation
    attr_reader :path, :name

    def initialize(path, name, line = nil)
      @path = path
      @name = name
      @line = line
    end

    def line
      @line ||= File.readlines(path).index do |line|
        line.match?(/^#{name}:/)
      end + 1
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
