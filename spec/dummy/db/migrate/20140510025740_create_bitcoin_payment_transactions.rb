class CreateBitcoinPaymentTransactions < ActiveRecord::Migration
  def change
    create_table :bitcoin_payment_transactions do |t|
      t.string :hash
      t.string :block_hash
      t.datetime :block_time
      t.datetime :estimated_time
    end
  end
end