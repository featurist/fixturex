# frozen_string_literal: true

class Forest < ApplicationRecord
  has_many :trees
  has_one :yongest_tree, class_name: 'Tree'
end
