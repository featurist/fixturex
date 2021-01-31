# frozen_string_literal: true

ActiveRecord::Schema.define(version: 1) do
  create_table :users, force: true do |t|
    t.column :name, :string
  end
end
