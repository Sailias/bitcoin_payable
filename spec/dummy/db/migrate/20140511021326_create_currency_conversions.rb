class CreateCurrencyConversions < ActiveRecord::Migration
  def change
    create_table :currency_conversions do |t|
      t.float "currency"
      t.integer "btc"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end