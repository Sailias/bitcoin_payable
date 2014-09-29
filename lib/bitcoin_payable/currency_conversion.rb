module BitcoinPayable
  class CurrencyConversion < ::ActiveRecord::Base
    validates :btc, presence: true
  end
end