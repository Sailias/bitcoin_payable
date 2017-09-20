class CreateBitcoinPaymentTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :bitcoin_payment_transactions do |t|
      t.integer :estimated_value
      t.string :transaction_hash
      t.string :block_hash
      t.datetime :block_time
      t.datetime :estimated_time
      t.integer :bitcoin_payment_id
      t.integer :btc_conversion
    end

    add_index :bitcoin_payment_transactions, :bitcoin_payment_id
  end
end