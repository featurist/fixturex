# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :finance_orders, class_name: 'Finance::Order'
  has_many :shipping_addresses
  has_one :billing_address

  has_many :subscriptions, class_name: 'Finance::Subscription'
  has_many :subscription_events, through: :subscription, class_name: 'Finance::SubscriptionEvent'
end
