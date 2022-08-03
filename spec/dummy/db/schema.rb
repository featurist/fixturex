# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveRecord::Schema.define(version: 1) do
  create_table :forest, force: true do |t|
    t.column :name, :string
  end

  create_table :attachments, force: true do |t|
    t.column :attachable_id, :integer
    t.column :attachable_type, :string
  end

  create_table :leaves, force: true do |t|
    t.column :tree_id, :integer
  end

  create_table :pictures, force: true do |t|
    t.column :imageable_id, :integer
    t.column :imageable_type, :string
  end

  create_table :posts, force: true do |t|
    t.column :name, :string
  end

  create_table :things, force: true do |t|
    t.column :name, :string
  end

  create_table :trees, force: true do |t|
    t.column :forest_id, :integer
  end

  create_table :trunks, force: true do |t|
    t.column :tree_id, :integer
  end

  create_table :writers, force: true do |t|
    t.column :name, :string
  end

  create_table :books, force: true do |t|
    t.column :name, :string
    t.column :writer_id, :integer
  end

  create_table :customers, force: true do |t|
    t.column :name, :string
  end

  create_table :finance_orders, force: true do |t|
    t.column :customer_id, :integer
  end

  create_table :finance_subscriptions, force: true do |t|
    t.column :customer_id, :integer
  end

  create_table :finance_subscription_events, force: true do |t|
    t.column :finance_subscription_id, :integer
  end

  create_table :addresses, force: true do |t|
    t.column :type, :string
    t.column :customer_id, :integer
  end

  create_table :votes, force: true do |t|
    t.column :post_id, :integer
  end
end
# rubocop:enable Metrics/BlockLength
