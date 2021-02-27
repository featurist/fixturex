# frozen_string_literal: true

class Address < ApplicationRecord
  self.abstract_class = true
  belongs_to :customer
end
