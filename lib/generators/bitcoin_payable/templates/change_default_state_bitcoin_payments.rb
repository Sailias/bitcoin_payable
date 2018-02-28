class ChangeDefaultStateBitcoinPayments < ActiveRecord::Migration<%= migration_version %>
  def change
    # Necesary to set a default. The gem state_machine is deprecated
    # and should be changed for state_machines-activerecord
    # but we'll just do this little hack to continiu support for rails 3
    change_column_default :bitcoin_payments, :state, :pending
  end
end
