class CreateCurrencyConversions < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :currency_conversions do |t|
      t.string :currency
      t.string :btc
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
