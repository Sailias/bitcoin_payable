require 'singleton'

module BitcoinPayable
  class Config
    include Singleton
    attr_accessor [
      :master_public_key,
      :node_path,
      :currency,
      :open_exchange_key,
      :testnet,
      :adapter,
      :adapter_api_key,
      :required_confirmations
    ]

    def initialize
      @currency ||= :cad
      @required_confirmations ||= 1
    end

    def network
      @testnet ||= true
      @testnet ? :bitcoin_testnet : :bitcoin
    end
  end
end
