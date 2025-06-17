class Parent < ApplicationRecord
  self.table_name = 'things'
  belongs_to :favorite_child, class_name: 'Child', optional: true
  has_many :children, class_name: 'Child'
end