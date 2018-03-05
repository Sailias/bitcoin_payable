class AddCryptoToBitcoinPayments < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :bitcoin_payments, :crypto, :string
  end
end
