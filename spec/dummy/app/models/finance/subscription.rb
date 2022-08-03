module Finance
  class Subscription < ApplicationRecord
    self.table_name = 'finance_subscriptions'
    has_many :subscription_events
  end
end
