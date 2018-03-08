module BitcoinPayable::Interactors
  class WebhookNotificationProcessor
    include Interactor

    def call
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      
      puts context.params.inspect
      address = context.params[:addresses].keys.last
      bitcoin_payment = BitcoinPayable::BitcoinPayment.find_by(address: address)

      if bitcoin_payment
        transaction = adapter.convert_transactions(context.params, address)
        BitcoinPayable::Interactors::TransactionProcessor::Organizer.call(
          bitcoin_payment: bitcoin_payment,
          transaction: transaction
        )
      end
    end

  end
end