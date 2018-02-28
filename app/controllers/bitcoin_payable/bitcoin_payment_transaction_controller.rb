require 'bitcoin_payable/commands/payment_processor'

module BitcoinPayable
  class BitcoinPaymentTransactionController < ActionController::Base
    http_basic_authenticate_with name: ENV['BITCOINPAYABLE_WEBHOOK_NAME'],
                                 password: ENV['BITCOINPAYABLE_WEBHOOK_PASS']

    # POST webhook
    #
    # Will only be used to give the user fast feedback so it'll save
    # Only transactions in the mempool will be considered
    # Only 0 confirmations as someone could post a tx woth 1000 confirmations
    # and make the app belive it's a secure transaction
    def notify_transaction
      return unless params[:event_type] == "address-transactions"
      address = params[:addresses].keys.last

      incoming_tx = BitcoinPaymentTransaction.format_transaction(params[:data],address)
      if incoming_tx[:confirmations] > 0
        render plain: '', status: :not_acceptable
        return
      end

      payment = BitcoinPayment.where(address: address).last!
      unless payment.transactions.find_by_transaction_hash(incoming_tx[:transaction_hash]).nil?
        render plain: '', status: :not_found
        return
      end

      payment.transactions.create!(incoming_tx)
      payment.update_after_new_transactions   # Not secure but will be monitored
      render plain: 'ok', template: false, status: :ok
    end

    # POST webhook
    #
    # Will triger the verification of the pending payments and transactions
    def last_block
      BitcoinPayable::PricingProcessor.update_rates_for_all_pairs
      PaymentProcessor.perform

      render plain: 'ok', status: :ok
    end

    private
  end
end
