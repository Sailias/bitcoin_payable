class AddBtcConversionToBitcoinPayments < ActiveRecord::Migration
  def change
    add_column :bitcoin_payments, :btc_conversion, :integer
  end
end