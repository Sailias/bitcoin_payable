module BitcoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def initialize
    end

    def perform
      BitcoinPayable::BitcoinPayment.where(state: [:pending, :partial_payment]).each do |payment|
        adapter = BitcoinPayable::Adapters::Base.fetch_adapter

        adapter.fetch_transactions_for_address(payment.address).each do |tx|
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

            payment.update(btc_amount_due: payment.calculate_btc_amount_due, btc_conversion: BitcoinPayable::CurrencyConversion.last.btc)
          end
        end

        if payment.currency_amount_paid >= payment.price
          payment.paid
        elsif payment.currency_amount_paid > 0
           payment.partially_paid
        end
      end
    end
  end
end