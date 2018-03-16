module BitcoinPayable::Interactors::TransactionProcessor
  class DeterminePaymentStatus
    include Interactor

    def call
      fiat_paid = context.bitcoin_payment.currency_amount_paid
      
      if fiat_paid >= context.bitcoin_payment.price
        context.bitcoin_payment.paid! unless context.bitcoin_payment.paid_in_full?
      elsif fiat_paid > 0
        context.bitcoin_payment.partially_paid!
      end
    end

  end
end