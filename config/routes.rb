Rails.application.routes.draw do
  if BitcoinPayable.config.allowwebhooks
    post 'bitcoin_payable/notifytransaction', to: 'bitcoin_payable/bitcoin_payment_transaction#notify_transaction'
  end
end
