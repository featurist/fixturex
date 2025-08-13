# frozen_string_literal: true

class User < ApplicationRecord
  self.table_name = 'things'
  has_many :posts
end