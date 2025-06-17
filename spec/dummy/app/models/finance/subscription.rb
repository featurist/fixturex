module Finance
  class Subscription < ApplicationRecord
    self.table_name = 'finance_subscriptions'
    has_many :subscription_events
    has_one :sftp_client  # This will reference SFTPClient but should resolve to Finance::SFTPClient
    belongs_to :customer
  end
end
