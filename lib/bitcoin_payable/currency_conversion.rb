module BitcoinPayable
  class CurrencyConversion < ::ActiveRecord::Base

    rails3?{ attr_accessible :currency, :rate, :crypto }
    
    validates :rate, presence: true

    def self.obtain(opts)
      opts[:currency] ||= BitcoinPayable.config.currency
      opts[:crypto] ||= BitcoinPayable.config.crypto
      conversion = CurrencyConversion.where(crypto: opts[:crypto], currency: opts[:currency])
      return conversion if conversion.any?
      begin
        [PricingProcessor.perform(crypto: opts[:crypto], currency: opts[:currency])]
      rescue JSON::ParserError => e
        raise e, "The currency you are trying to get isn't supported: #{e}"
      end
    end

  end
end
