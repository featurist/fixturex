# frozen_string_literal: true

class Attachment < ApplicationRecord
  # TODO: :class_name
  belongs_to :attachable, polymorphic: true
end
