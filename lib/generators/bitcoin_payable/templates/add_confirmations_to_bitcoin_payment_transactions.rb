class AddConfirmationsToBitcoinPaymentTransactions < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :bitcoin_payment_transactions, :confirmations, :integer
  end
end
