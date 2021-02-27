# frozen_string_literal: true

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', optional: true
end
