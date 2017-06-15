module BitcoinPayable::Adapters
  class Base

    def self.fetch_adapter
      case BitcoinPayable.config.adapter
      when "blockchain_info"
        BitcoinPayable::Adapters::BlockchainInfoAdapter.new
      when "blockcypher"
        BitcoinPayable::Adapters::BlockcypherAdapter.new
      else
        raise "Please specify an adapter"
      end
    end

  end
end
