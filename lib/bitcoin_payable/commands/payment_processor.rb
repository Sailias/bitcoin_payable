module BitcoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def initialize
    end

    def perform
      BitcoinPayable::BitcoinPayment.where(state: [:pending, :partial_payment]).each do |payment|
        transactions = HelloBlock::Transaction.where(addresses: [payment.address]).to_hash
        if transactions["data"]
          transactions["data"]["transactions"].each do |tx|
            unless payment.transactions.find_by_transaction_hash(tx["txHash"])
              payment.transactions.create!(
                estimated_value: tx["estimatedTxValue"],
                transaction_hash: tx["txHash"],
                block_hash: tx["blockHash"],
                block_time: (Time.at(tx["blockTime"]) if tx["blockTime"]),
                estimated_time: (Time.at(tx["estimatedTxTime"]) if tx["estimatedTxTime"]),
                btc_conversion: BitcoinPayable::CurrencyConversion.last.btc
              )

              payment.update(btc_amount_due: payment.calculate_btc_amount_due)
            end
          end
        end

        if payment.currency_amount_paid >= (payment.price / 100.0)
          payment.paid
        elsif payment.currency_amount_paid > 0
           payment.partially_paid
        end
      end
    end
  end
end