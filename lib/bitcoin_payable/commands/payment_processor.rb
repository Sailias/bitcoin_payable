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
              tx.symbolize_keys!
              unless payment.transactions.find_by_transaction_hash(tx[:txHash])
                payment.transactions.create!(
                  estimated_value: tx[:estimatedTxValue],
                  transaction_hash: tx[:txHash],
                  block_hash: tx[:blockHash],
                  block_time: (Time.at(tx[:blockTime]) if tx[:blockTime]),
                  estimated_time: (Time.at(tx[:estimatedTxTime]) if tx[:estimatedTxTime]),
                  btc_conversion: payment.btc_conversion
                )

                payment.update_after_new_transactions
              end
            end
          rescue JSON::ParserError
            puts "Error processing response from server.  Possible API issue or your Quota has been exceeded"
          end
        end

      end
    end

    protected

    def check_paid(payment)
      if payment.currency_amount_paid >= payment.price
        payment.paid
      elsif payment.currency_amount_paid > 0
         payment.partially_paid
      end
    end

  end

end
