require 'net/http'
require 'interactor'
require 'bitcoin_payable/config'
require 'bitcoin_payable/version'
require 'bitcoin_payable/has_bitcoin_payment'
require 'bitcoin_payable/tasks'
require 'bitcoin_payable/bitcoin_calculator'

require 'bitcoin_payable/engine'

# Require all the adapter files
require 'bitcoin_payable/adapters/base'
require 'bitcoin_payable/adapters/blockchain_info_adapter'
require 'bitcoin_payable/adapters/blockcypher_adapter'
require 'bitcoin_payable/adapters/blocktrail_adapter'

# Require all the interactor files
require 'bitcoin_payable/interactors/webhook_notification_processor'
require 'bitcoin_payable/interactors/transaction_processor/process_transaction'
require 'bitcoin_payable/interactors/transaction_processor/update_payment_amounts'
require 'bitcoin_payable/interactors/transaction_processor/organizer'
require 'bitcoin_payable/interactors/bitcoin_payment_processor/determine_payment_status'
require 'bitcoin_payable/interactors/bitcoin_payment_processor/process_transactions_for_payment'

module BitcoinPayable
  def self.config(&block)
    @@config ||= BitcoinPayable::Config.instance
    block_given? ? block.call(@@config) : @@config
  end
end

require 'bitcoin_payable/bitcoin_payment_transaction'
require "bitcoin_payable/address"
require 'bitcoin_payable/bitcoin_payment'

require 'bitcoin_payable/currency_conversion'

ActiveSupport.on_load(:active_record) do
  include BitcoinPayable::Model
end
