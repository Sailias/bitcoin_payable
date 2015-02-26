require 'helloblock'

module BitcoinPayable::Adapters
  class HelloBlockAdapter < BitcoinPayable::Adapters::Base

    def initialize
      HelloBlock.network = :mainnet unless BitcoinPayable.config.testnet
    end

    def fetch_transactions_for_address(address)
      HelloBlock::Transaction.where(addresses: [address]).to_hash
      if transactions["data"]
        transactions["data"]["transactions"]
      else 
        []
      end
    end

  end
end