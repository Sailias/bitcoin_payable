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

            # Cloudflare limits requests to 1200 req / 5 minutes
            # or 4 requests / 1 second
            # So we will sleep for 500ms after each request by default
            sleep(BitcoinPayable.config.request_delay.to_f)
          rescue JSON::ParserError
            puts "Error processing response from server.  Possible API issue or your Quota has been exceeded"
          end
        end
    end
  end
end