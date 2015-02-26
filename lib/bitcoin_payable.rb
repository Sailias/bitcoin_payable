require 'net/http'
require 'bitcoin_payable/config'
require 'bitcoin_payable/version'
require 'bitcoin_payable/has_bitcoin_payment'
require 'bitcoin_payable/tasks'
require 'bitcoin_payable/bitcoin_calculator'

require 'helloblock'
require 'bitcoin_payable/adapters/base'
require 'bitcoin_payable/adapters/hello_block_adapter'
require 'bitcoin_payable/adapters/blockchain_info_adapter'

module BitcoinPayable
  def self.config
    @@config ||= BitcoinPayable::Config.instance
  end
end

require 'bitcoin_payable/bitcoin_payment_transaction'
require "bitcoin_payable/address"
require 'bitcoin_payable/bitcoin_payment'

require 'bitcoin_payable/currency_conversion'

ActiveSupport.on_load(:active_record) do
  include BitcoinPayable::Model
end
