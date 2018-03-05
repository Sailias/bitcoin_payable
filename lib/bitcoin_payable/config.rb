require 'singleton'

module BitcoinPayable
  class Config
    include Singleton
    attr_accessor :master_public_key, :node_path, :currency, :open_exchange_key,
                  :testnet, :adapter, :adapter_api_key, :allowwebhooks, :webhook_domain,
                  :webhook_port, :auto_calculate_rate_every

    def initialize
      @currency ||= :cad
    end

    def network
      @testnet == false ? :bitcoin : :bitcoin_testnet
    end
  end
end
