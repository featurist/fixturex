# frozen_string_literal: true

class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true
end
