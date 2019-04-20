module BitcoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def perform
      BitcoinPayable::BitcoinPayment.
        where(state: [:pending, :partial_payment, :paid_in_full]).
        where("created_at > ?", (BitcoinPayable.config.processing_days.to_i).days.ago).each do |payment|
          begin
            BitcoinPayable::Interactors::BitcoinPaymentProcessor::ProcessTransactionsForPayment.call(
              payment: payment
            )
          rescue JSON::ParserError
            puts "Error processing response from server.  Possible API issue or your Quota has been exceeded"
          end
        end
    end
  end
end