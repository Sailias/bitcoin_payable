module BitcoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def initialize
    end

    def perform
      BitcoinPayable::BitcoinPayment.where(state: [:pending, :partial_payment]).each do |payment|
        unless payment.paid_in_full?
          begin
            adapter = BitcoinPayable::Adapters::Base.fetch_adapter

            adapter.fetch_transactions_for_address(payment.address).each do |tx|
              next if tx.nil?

              BitcoinPayable::Interactors::TransactionProcessor::Organizer.call(
                bitcoin_payment: payment,
                transaction: tx
              )
            end

            sleep(0.25)
          rescue JSON::ParserError
            puts "Error processing response from server.  Possible API issue or your Quota has been exceeded"
          end
        end

      end
    end

  end

end
