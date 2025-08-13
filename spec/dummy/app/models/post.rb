# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  has_one :attachment, as: :attachable
  has_many :pictures, as: :imageable

  # handles one direction associations (e.g. has_many without belongs_to on the other end)
  has_many :votes
end
