class AddConfirmationsBlockNToBtcPaymentTransactions < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :bitcoin_payment_transactions, :confirmations, :integer
    add_column :bitcoin_payment_transactions, :block_number, :integer
  end
end
