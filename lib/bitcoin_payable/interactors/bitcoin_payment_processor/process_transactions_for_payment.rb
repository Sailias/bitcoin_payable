module BitcoinPayable::Interactors::BitcoinPaymentProcessor
  class ProcessTransactionsForPayment
    include Interactor

    def call
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      adapter.fetch_transactions_for_address(context.payment.address).each do |tx|
        next if tx.nil?

        BitcoinPayable::Interactors::TransactionProcessor::Organizer.call(
          bitcoin_payment: context.payment,
          transaction: tx
        )
      end

      # Determine the status of this payment even if there are no transactions
      # Could be comped or discounted
      BitcoinPayable::Interactors::BitcoinPaymentProcessor::DeterminePaymentStatus.call(
        bitcoin_payment: context.payment
      )
    end

  end
end
