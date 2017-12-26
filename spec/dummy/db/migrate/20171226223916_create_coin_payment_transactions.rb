class CreateCoinPaymentTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :coin_payment_transactions do |t|
      t.integer :estimated_value, limit: 8
      t.string :transaction_hash
      t.string :block_hash
      t.datetime :block_time
      t.datetime :estimated_time
      t.integer :coin_payment_id
      t.integer :coin_conversion, limit: 8
      t.integer :confirmations
    end

    add_index :coin_payment_transactions, :coin_payment_id
  end
end
