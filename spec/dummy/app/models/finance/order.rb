module Finance
  class Order < ApplicationRecord
    self.table_name = 'finance_orders'
    belongs_to :customer
  end
end
