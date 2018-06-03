class ChangeColumTypeForCurrencyInCurrencyConversion < ActiveRecord::Migration<%= migration_version %>
  def change
    change_column :currency_conversions, :currency, :string
  end
end
