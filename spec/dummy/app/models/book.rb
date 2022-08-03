# frozen_string_literal: true

class Book < ApplicationRecord
  belongs_to :author, class_name: 'Writer', optional: true
end
