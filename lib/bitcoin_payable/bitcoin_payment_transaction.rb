module BitcoinPayable
  class BitcoinPaymentTransaction < ::ActiveRecord::Base
    belongs_to :bitcoin_payment

    before_save :add_block_n_conversion

    def self.format_transaction(transaction, recepient_address)
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      adapter.convert_transactions(transaction, recepient_address)
    end

    def secure?
      return false if confirmations < BitcoinPayable.config.confirmations
      return true if confirmations >= BitcoinPayable.config.confirmations
    end

    private
    def add_block_n_conversion
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      self.block_number ||= adapter.get_last_block
      self.btc_conversion ||= bitcoin_payment.btc_conversion
    end
  end
end
