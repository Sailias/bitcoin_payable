module BitcoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def initialize
      @adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      @last_block = @adapter.get_last_block
    end

    def perform
      # We will evaluate transactions from pending payments and transactions
      # from paid payments with unsecure tx, with not enought confirmations
      payments_with_unsecure_tx = BitcoinPayment.joins(:transactions)
                                    .where(bitcoin_payment_transactions: {confirmations: 0..BitcoinPayable.config.confirmations})
      payments_with_unsecure_tx.uniq.readonly(false) unless payments_with_unsecure_tx.empty?

      payments_pending_or_partial = BitcoinPayable::BitcoinPayment.where(state: [:pending, :partial_payment])
      payments_to_review = (payments_with_unsecure_tx + payments_pending_or_partial).uniq{|payment| payment.id}

      payments_to_review.each do |payment|
        transactions = @adapter.fetch_transactions_for_address(payment.address)
        next if transactions.nil?

        transactions.each do |incoming_tx|
          incoming_tx.symbolize_keys!
          stored_transaction = payment.transactions.find_by_transaction_hash(incoming_tx[:transaction_hash])
          if stored_transaction
            if stored_transaction.secure?
              payment.update_after_new_transactions
            else
              stored_transaction.update_attributes(incoming_tx)
            end
          else # store new transaction
            stored_transaction = payment.transactions.create!(incoming_tx)
            payment.update_after_new_transactions if  stored_transaction.secure? || BitcoinPayable.config.zero_tx
          end
          @adapter.desuscribe_address_from_notifications(payment.address)
        end
      end
      verify_left_behid_txs
    end

    private
    # If a transaction doesn't keep getting deep into the blockchain it means
    # it's a double spend, a fork in the network or some other problem such as
    # low fee transaction. Confirmations need to grow with the block-heihgt.
    # We'll monitor while confirmations are less than BitcoinPayable.config.confirmations
    def verify_left_behid_txs
      BitcoinPaymentTransaction.where(confirmations: 0...BitcoinPayable.config.confirmations).each do |unsecure_tx|
        blocks_since_last_confirmation = @last_block - unsecure_tx[:block_number]
        if blocks_since_last_confirmation > 3 # Something is wrong with this transaction
          unsecure_tx.update_attributes(confirmations: -1)
          unsecure_tx.bitcoin_payment.update_after_new_transactions
        end
      end
    end
  end
end
