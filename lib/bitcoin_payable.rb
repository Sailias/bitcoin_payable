require 'net/http'
require 'bitcoin_payable/config'
require 'bitcoin_payable/version'
require 'bitcoin_payable/has_bitcoin_payment'
require 'bitcoin_payable/tasks'
require 'bitcoin_payable/bitcoin_calculator'

require 'blockcypher'
require 'bitcoin_payable/adapters/base'
require 'bitcoin_payable/engine'

require 'bitcoin_payable/rails3_port'

module BitcoinPayable
  def self.config(&block)
    @@config ||= BitcoinPayable::Config.instance
    block_given? ? block.call(@@config) : @@config
  end

  Object.include(BitcoinPayable::Rails3support)
end



require 'bitcoin_payable/bitcoin_payment_transaction'
require "bitcoin_payable/address"
require 'bitcoin_payable/bitcoin_payment'

require 'bitcoin_payable/currency_conversion'

ActiveSupport.on_load(:active_record) do
  include BitcoinPayable::Model
end
