require 'bitcoin_payable/commands/payment_processor'

module BitcoinPayable
  class BitcoinPaymentTransactionController < ActionController::Base
    http_basic_authenticate_with name: ENV['BITCOINPAYABLE_WEBHOOK_NAME'],
                                 password: ENV['BITCOINPAYABLE_WEBHOOK_PASS']

    # POST bitcoin/notifytransaction
    def notify_transaction
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      address = adapter.extract_address_from_incoming_tx(params)

      incoming_tx = BitcoinPaymentTransaction.format_transaction(params,address)

      payment = BitcoinPayment.where(address: address).last!
      unless payment.transactions.find_by_transaction_hash(incoming_tx[:transaction_hash]).nil?
        render plain: '', template:false, status: :not_found
        return
      end

      payment.transactions.create!(incoming_tx)
      payment.update_after_new_transactions    # Not secure but will be monitored
      render plain: 'ok', template:false, status: :ok
    end

    # POST last_block
    def last_block
      PaymentProcessor.perform
      last_rate_cheked = CurrencyConversion.pluck(:updated_at).last
      if last_rate_cheked < BitcoinPayable.config.auto_calculate_rate_every.ago
        PricingProcessor.perform
      end

      render plain: 'ok', template:false, status: :ok
    end

    private
  end
end
