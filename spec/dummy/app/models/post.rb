# frozen_string_literal: true

class Post < ApplicationRecord
  has_one :attachment, as: :attachable
  has_many :pictures, as: :imageable
end
