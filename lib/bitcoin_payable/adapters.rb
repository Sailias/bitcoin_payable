module BitcoinPayable
  module Adapters
    require_relative 'adapters/coin.rb'
    require_relative 'adapters/bitcoin.rb'
    require_relative 'adapters/ethereum.rb'

    def self.for(coin_type)
      case coin_type.to_sym
      when :eth
        Ethereum
      when :btc
        Bitcoin
      else
        raise "Invalid coin type #{coin_type}"
      end
    end
  end
end
