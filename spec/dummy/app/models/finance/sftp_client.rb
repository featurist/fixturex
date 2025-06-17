module Finance
  class SftpClient < ApplicationRecord
    self.table_name = 'things'
    belongs_to :subscription, class_name: 'Finance::Subscription'
  end
end