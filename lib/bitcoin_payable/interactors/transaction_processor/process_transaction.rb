module BitcoinPayable::Interactors::TransactionProcessor
  class ProcessTransaction
    include Interactor

    def call
      context.bitcoin_payment_transaction = context.bitcoin_payment.transactions.find_by_transaction_hash(context.transaction[:txHash])
      
      if context.bitcoin_payment_transaction
        # We have this transaction, update it's number of confirmations
        context.bitcoin_payment_transaction.update(confirmations: context.transaction[:confirmations])
      else
        # We have never seen this transaction, let's create it
        context.bitcoin_payment_transaction = context.bitcoin_payment.transactions.create!(
          estimated_value: context.transaction[:estimatedTxValue],
          transaction_hash: context.transaction[:txHash],
          block_hash: context.transaction[:blockHash],
          block_time: (Time.at(context.transaction[:blockTime]) if context.transaction[:blockTime]),
          estimated_time: (Time.at(context.transaction[:estimatedTxTime]) if context.transaction[:estimatedTxTime]),
          btc_conversion: context.bitcoin_payment.btc_conversion,
          confirmations: context.transaction[:confirmations]
        )
      end
    end

  end
end