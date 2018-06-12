module BitcoinPayable::Interactors::TransactionProcessor
  class UpdatePaymentAmounts
    include Interactor

    def call
      context.bitcoin_payment.update_attributes(
        btc_amount_due: context.bitcoin_payment.calculate_btc_amount_due,
        btc_conversion: BitcoinPayable::CurrencyConversion.last_rate_for(context.bitcoin_payment.currency)
      )
    end

  end
end
