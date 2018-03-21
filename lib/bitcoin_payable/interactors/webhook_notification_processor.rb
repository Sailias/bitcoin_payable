module BitcoinPayable::Interactors
  class WebhookNotificationProcessor
    include Interactor

    def call
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter

      bitcoin_payment = BitcoinPayable::BitcoinPayment.find(context.params[:bitcoin_payment_id])
      address = context.params[:addresses].keys.last
      # bitcoin_payment = BitcoinPayable::BitcoinPayment.find_by(address: address)

      if bitcoin_payment && bitcoin_payment.address == address
        transaction = adapter.convert_transactions(context.params, address)
        BitcoinPayable::Interactors::TransactionProcessor::Organizer.call(
          bitcoin_payment: bitcoin_payment,
          transaction: transaction
        )
      end
    end

  end
end