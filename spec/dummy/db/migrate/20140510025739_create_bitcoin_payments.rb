class CreateBitcoinPayments < ActiveRecord::Migration
  def change
    create_table :bitcoin_payments do |t|
      t.string   :payable_type
      t.integer  :payable_id
      t.string   :currency
      t.string   :reason
      t.integer  :amount_due
      t.string   :address
      t.string   :state
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :amount_paid, default: 0
    end
    add_index :bitcoin_payments, [:payable_type, :payable_id]
  end
end