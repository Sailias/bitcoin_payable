module BitcoinPayable::Interactors
  class WebhookNotificationProcessor
    include Interactor

    def call
      address = context.params[:addresses].keys.last
      bitcoin_payment = BitcoinPayable::BitcoinPayment.find_by(address: address)

      if bitcoin_payment
        transaction = BitcoinPayable::BitcoinPaymentTransaction.format_transaction(context.params, address)
        BitcoinPayable::Interactors::TransactionProcessor::Organizer.call(
          bitcoin_payment: bitcoin_payment,
          transaction: transaction
        )
      end
    end

  end
end
