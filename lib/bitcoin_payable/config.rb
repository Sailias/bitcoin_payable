module BitcoinPayable
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :currency, :open_exchange_key, :testnet, :btc, :eth

    def initialize
      @currency ||= :usd
    end

    def configure_btc
      self.btc ||= BtcConfiguration.new
      yield(btc)
    end

    def configure_eth
      self.eth ||= EthConfiguration.new
      yield(eth)

      # TODO: Put this somewhere better.
      Eth.configure do |config|
        config.chain_id = BitcoinPayable.configuration.eth.chain_id
      end
    end

    private

    class CoinConfiguration
      attr_accessor :node_path, :confirmations, :adapter_api_key, :network
    end

    class BtcConfiguration < CoinConfiguration
      attr_accessor :master_public_key

      def confirmations
        @confirmations ||= 3
      end

      def network
        BitcoinPayable.configuration.testnet == false ? :bitcoin : :bitcoin_testnet
      end
    end

    class EthConfiguration < CoinConfiguration
      attr_accessor :mnemonic, :chain_id

      def confirmations
        @confirmations ||= 12
      end

      def chain_id
        @chain_id ||= (BitcoinPayable.configuration.testnet ? 4 : 1)
      end

      def network
        @network ||= (BitcoinPayable.configuration.testnet ? :rinkeby : :mainnet)
      end
    end
  end
end
