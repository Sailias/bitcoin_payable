module BitcoinPayable
  class BitcoinPaymentTransaction < ::ActiveRecord::Base

    belongs_to :bitcoin_payment

    before_save :add_conversion

    def add_conversion
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      self.btc_conversion ||= bitcoin_payment.btc_conversion
    end

    def secure?
      return true if self.confirmations >= BitcoinPayable.config.confirmations 
      return false
    end
  end
end
