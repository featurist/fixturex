module Subscriptions
  class Cart < ApplicationRecord
    self.table_name = 'things'
    has_many :versions, class_name: 'PaperTrail::Version', as: :item
  end
end