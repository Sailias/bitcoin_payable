require 'singleton'

module BitcoinPayable
  class Config
    include Singleton
    attr_accessor :master_seed, :currency, :testnet, :open_exchange_key

    def initialize
      @currency ||= :cad
      @testnet ||= false
    end
  end
end