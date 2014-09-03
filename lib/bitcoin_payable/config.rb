require 'singleton'

module BitcoinPayable
  class Config
    include Singleton
    attr_accessor :master_public_key, :node_path, :currency, :open_exchange_key, :testnet

    def initialize
      @currency ||= :cad
    end
  end
end