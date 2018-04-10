module BitcoinPayable
  class CurrencyConversion < ::ActiveRecord::Base
    validates :btc, presence: true

    def self.last_rate_for(currency)
      PricingProcessor.new(currency: currency).perform unless self.where(currency: currency).any?
      self.where(currency: currency).last.btc
    end

  end
end
