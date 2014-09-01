module BitcoinPayable
  class Address

    def self.create(id)
      if BitcoinPayable.config.master_seed
        config = {
          seed_hex: BitcoinPayable.config.master_seed
        }
        config.merge!(network: :bitcoin_testnet) if BitcoinPayable.config.testnet
        master = MoneyTree::Master.new config
        node = master.node_for_path "m/0/#{id}"

      elsif BitcoinPayable.config.master_public_key
        master = MoneyTree::Node.from_serialized_address BitcoinPayable.config.master_public_key
        node = master.node_for_path id.to_s
      else
        raise "MASTER_SEED or MASTER_PUBLIC_KEY is required"
      end

      node.to_address
    end

  end
end