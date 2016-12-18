module BitcoinPayable
  class Address

    def self.create(id)
      if BitcoinPayable.config.master_public_key
        master = MoneyTree::Node.from_serialized_address BitcoinPayable.config.master_public_key
        node = master.node_for_path BitcoinPayable.config.node_path + id.to_s
      else
        raise "MASTER_SEED or MASTER_PUBLIC_KEY is required"
      end

      node.to_address(network: BitcoinPayable.config.network)
    end

  end
end
