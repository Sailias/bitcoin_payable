module BitcoinPayable::Adapters
  class Base

    def self.fetch_adapter
      case BitcoinPayable.config.adapter
      when "helloblock"
        BitcoinPayable::Adapters::HelloBlockAdapter.new
      when "blockchain_info"
        BitcoinPayable::Adapters::BlockchainInfoAdapter.new
      else
        raise "Please specify an adapter"
      end
    end

  end
end