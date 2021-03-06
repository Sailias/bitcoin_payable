module BitcoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def perform
      BitcoinPayable::BitcoinPayment.
        where(state: [:pending, :partial_payment, :paid_in_full]).
        where("created_at > ?", (BitcoinPayable.config.processing_days.to_i).days.ago).each do |payment|
          sleep_amount = BitcoinPayable.config.request_delay.to_f

          begin
            puts "Checking address: #{ payment.address }"
            BitcoinPayable::Interactors::BitcoinPaymentProcessor::ProcessTransactionsForPayment.call(
              payment: payment
            )
          rescue JSON::ParserError
            # Back off for 60 seconds as most APIs throttle in request/min window
            sleep_amount = 60

            puts "Error processing response from server.  Possible API issue or your Quota has been exceeded"
          end

          # Cloudflare limits requests to 1200 req / 5 minutes
          # or 4 requests / 1 second
          # So we will sleep for 500ms after each request by default
          sleep(sleep_amount)
        end
    end
  end
end