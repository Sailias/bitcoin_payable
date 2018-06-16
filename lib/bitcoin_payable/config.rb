require 'singleton'

module BitcoinPayable
  class Config
    include Singleton
    attr_accessor(
      # Core
      :master_public_key,
      :node_path,
      :currency,
      :adapter,
      :adapter_api_key,
      :testnet,
      :confirmations,
      :crypto,

      # Pricing
      :open_exchange_key,
      :rate_calculation,

      # Webhooks
      :allowwebhooks,
      :webhook_subdomain,
      :webhook_domain,
      :webhook_protocol
    )

    def initialize
      @currency ||= :cad
      @confirmations ||= 6
      @rate_calculation ||= :daily_average
      @crypto ||= :btc
    end

    def network
      @testnet == false ? :bitcoin : :bitcoin_testnet
    end
  end
end
