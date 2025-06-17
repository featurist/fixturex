class Child < ApplicationRecord
  self.table_name = 'things'
  belongs_to :parent
  has_one :favorite_parent, class_name: 'Parent', foreign_key: 'favorite_child_id'
end