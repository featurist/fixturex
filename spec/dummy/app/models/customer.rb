# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :finance_orders, class_name: 'Finance::Order'
  has_many :shipping_addresses
  has_one :billing_address
end
