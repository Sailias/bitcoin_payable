require 'net/http'
require 'blockcypher'

require 'bitcoin_payable/config'
require 'bitcoin_payable/version'
require 'bitcoin_payable/has_coin_payments'
require 'bitcoin_payable/tasks'
require 'bitcoin_payable/adapters'
require 'bitcoin_payable/coin_payment_transaction'
require 'bitcoin_payable/coin_payment'
require 'bitcoin_payable/currency_conversion'

module BitcoinPayable
end

ActiveSupport.on_load(:active_record) do
  include BitcoinPayable::Model
end
