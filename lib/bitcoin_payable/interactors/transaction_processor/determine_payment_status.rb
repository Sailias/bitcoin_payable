module BitcoinPayable::Interactors::TransactionProcessor
  class DeterminePaymentStatus
    include Interactor

    def call
      fiat_paid = context.bitcoin_payment.currency_amount_paid
      
      if fiat_paid >= context.bitcoin_payment.price
        handle_paid_in_full
      elsif fiat_paid > 0
        handle_partial_paid
      end
    end

    private

    def handle_paid_in_full
      if context.bitcoin_payment_transaction.confirmations >= BitcoinPayable.config.confirmations
        # This payment is already paid in full, we should check the confirmation count
        context.bitcoin_payment.confirm!
      else
        # This payment has not been marked as paid yet, let's mark it
        context.bitcoin_payment.paid! unless context.bitcoin_payment.paid_in_full?
      end
    end

    def handle_partial_paid
      unless context.bitcoin_payment.partial_payment?
        context.bitcoin_payment.partially_paid! 
      end
    end

  end
end