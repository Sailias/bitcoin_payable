class AddBtcConversionToBitcoinPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :bitcoin_payments, :btc_conversion, :integer
  end
end