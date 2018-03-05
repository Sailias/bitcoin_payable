class AddBtcConversionToBitcoinPayments < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :bitcoin_payments, :btc_conversion, :integer
  end
end
