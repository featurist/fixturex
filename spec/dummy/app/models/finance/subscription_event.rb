module Finance
  class SubscriptionEvent < ApplicationRecord
    self.table_name = 'finance_subscription_events'
    belongs_to :subscription, class_name: 'Finance::Subscription'
  end
end
