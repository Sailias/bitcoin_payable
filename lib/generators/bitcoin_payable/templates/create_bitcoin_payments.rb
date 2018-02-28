class CreateBitcoinPayments < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :bitcoin_payments do |t|
      t.string   :payable_type
      t.integer  :payable_id
      t.string   :currency
      t.string   :crypto
      t.string   :reason
      t.integer  :price
      t.float    :btc_amount_due, default: 0
      t.string   :address

      # Necesary to set a default. The gem state_machine is deprecated
      # and should be changed for state_machines-activerecord
      # but we'll just do this little hack to continiu support for rails 3
      t.string   :state, default: :pending

      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :bitcoin_payments, [:payable_type, :payable_id]
  end
end
