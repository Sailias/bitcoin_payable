class AddCryptoAndChangeNameBtcInCurrencyConversions < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :currency_conversions, :rate, :string
    rename_column :currency_conversions, :btc, :crypto
  end
end
