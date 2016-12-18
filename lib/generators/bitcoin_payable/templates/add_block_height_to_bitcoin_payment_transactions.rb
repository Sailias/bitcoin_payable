class AddBlockHeightToBitcoinPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :bitcoin_payment_transactions, :block_height, :integer
  end
end