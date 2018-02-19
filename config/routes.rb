Rails.application.routes.draw do
    if BitcoinPayable.config.allowwebhooks
      if BitcoinPayable.config.zero_tx
        post 'bitcoin/notifytransaction',
          to: 'bitcoin_payable/bitcoin_payment_transaction#notify_transaction'
      end
      post 'bitcoin/lastblock', to: 'bitcoin_payable/bitcoin_payment_transaction#last_block'
    end
end
