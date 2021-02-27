# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :finance_orders, class_name: 'Finance::Order'
end
