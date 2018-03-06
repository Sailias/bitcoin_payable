Rails.application.routes.draw do
    if BitcoinPayable.config.allowwebhooks
      post 'bitcoin/notifytransaction', to: 'bitcoin_payable/bitcoin_payment_transaction#notify_transaction'
      post 'bitcoin/lastblock', to: 'bitcoin_payable/bitcoin_payment_transaction#last_block'
    end
end
