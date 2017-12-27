module BitcoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def initialize
    end

    def perform
      BitcoinPayable::BitcoinPayment.where(state: [:pending, :partial_payment, :paid_in_full]).each do |payment|
        # => Check for completed payment first, incase it's 0 and we don't need to make an API call
        # => Preserve API calls
        update_payment_state(payment)

        unless payment.confirmed?
          begin
            adapter = BitcoinPayable::Adapters::Base.fetch_adapter

            adapter.fetch_transactions_for_address(payment.address).each do |tx|
              tx.symbolize_keys!

              transaction = payment.transactions.find_by_transaction_hash(tx[:txHash])
              if transaction
                transaction.update(confirmations: tx[:confirmations])
              else
                payment.transactions.create!(
                  estimated_value: tx[:estimatedTxValue],
                  transaction_hash: tx[:txHash],
                  block_hash: tx[:blockHash],
                  block_time: (Time.at(tx[:blockTime]) if tx[:blockTime]),
                  estimated_time: (Time.at(tx[:estimatedTxTime]) if tx[:estimatedTxTime]),
                  btc_conversion: payment.btc_conversion,
                  confirmations: tx[:confirmations]
                )

                payment.update(btc_amount_due: payment.calculate_btc_amount_due, btc_conversion: BitcoinPayable::CurrencyConversion.last.btc)
              end
            end

            # => Check for payments after the response comes back
            update_payment_state(payment)

          rescue JSON::ParserError
            puts "Error processing response from server. Possible API issue or your Quota has been exceeded"
          end
        end

      end
    end

    protected

    def update_payment_state(payment)
      if payment.currency_amount_paid >= payment.price
        payment.paid
        if payment.transactions_confirmed?
          payment.confirmed
        end
      elsif payment.currency_amount_paid > 0
        payment.partially_paid
      end
    end
  end
end
