Rails.application.routes.draw do
  if BitcoinPayable.config.allowwebhooks
    post 'bitcoin_payable/notify_transaction/:bitcoin_payment_id', to: 'bitcoin_payable/bitcoin_payment_transaction#notify_transaction'
  end
end
