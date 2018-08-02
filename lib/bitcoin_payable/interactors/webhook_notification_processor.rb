module BitcoinPayable::Interactors
  class WebhookNotificationProcessor
    include Interactor

    def call
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter

      bitcoin_payment = BitcoinPayable::BitcoinPayment.find(context.params[:bitcoin_payment_id])
      address = context.params[:addresses].keys.last

      if bitcoin_payment && bitcoin_payment.address == address
        transaction = adapter.convert_transactions(context.params, address)
        
        BitcoinPayable::Interactors::TransactionProcessor::Organizer.call(
          bitcoin_payment: bitcoin_payment,
          transaction: transaction
        )

        BitcoinPayable::Interactors::BitcoinPaymentProcessor::DeterminePaymentStatus.call(
          bitcoin_payment: bitcoin_payment
        )
      end
    end

  end
end