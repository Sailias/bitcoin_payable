require 'blockcypher'

module BitcoinPayable
  module Adapters
    class Bitcoin < Coin
      SATOSHI_IN_BITCOIN = 100_000_000

      def self.convert_subunit_to_main(satoshis)
        satoshis / SATOSHI_IN_BITCOIN.to_f
      end

      def self.convert_main_to_subunit(bitcoins)
        (bitcoins * SATOSHI_IN_BITCOIN).to_i
      end

      # @param price: cents in fiat currency
      # @param exchange_rate: fiat cents per bitcoin
      # @returns price in satoshi
      def self.exchange_price(price, exchange_rate)
        (price / exchange_rate.to_f * SATOSHI_IN_BITCOIN).ceil
      end

      def self.get_rate
        super('BTC')
      end

      def self.get_transactions_for(address)
        address_full_txs = adapter.address_full_txs(address)
        address_full_txs['txs'].map { |tx| convert_transactions(tx, address) }
      end

      def self.create_address(id)
        key = BitcoinPayable.configuration.btc.master_public_key

        raise 'master_public_key is required' unless key

        master = MoneyTree::Node.from_bip32(key)
        node = master.node_for_path(BitcoinPayable.configuration.btc.node_path + id.to_s)
        node.to_address(network: BitcoinPayable.configuration.btc.network)
      end

      private_class_method def self.adapter
        @adapter ||= if BitcoinPayable.configuration.testnet
          BlockCypher::Api.new(network: BlockCypher::TEST_NET_3)
        else
          BlockCypher::Api.new
        end
      end

      private_class_method def self.convert_transactions(transaction, address)
        {
          txHash: transaction['hash'],
          blockHash: transaction['block_hash'],
          blockTime: transaction['confirmed'].nil? ? nil : DateTime.iso8601(transaction['confirmed']),
          estimatedTxTime: DateTime.iso8601(transaction['received']),
          estimatedTxValue: transaction['outputs'].sum { |out| out['addresses'].join.eql?(address) ? out['value'] : 0 },
          confirmations: transaction['confirmations']
        }
      end
    end
  end
end
