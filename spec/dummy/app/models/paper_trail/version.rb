module PaperTrail
  class Version < ApplicationRecord
    self.table_name = 'things'
    belongs_to :item, polymorphic: true
  end
end