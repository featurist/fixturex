module Fixturex
  TreeEntry = Struct.new(:value, :children) do
    def to_h
      {
        value: value.to_h,
        children: children.map(&:to_h)
      }
    end
  end
end
