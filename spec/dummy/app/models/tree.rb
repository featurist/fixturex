# frozen_string_literal: true

class Tree < ApplicationRecord
  belongs_to :forest
  has_many :leaves
  has_one :trunk
end
