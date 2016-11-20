require 'blockcypher'
module BitcoinPayable::Adapters
  class BlockcypherAdapter

    def initialize
      if BitcoinPayable.config.testnet
        @blockcypher = BlockCypher::Api.new(network: BlockCypher::TEST_NET_3)
      else
        @blockcypher = BlockCypher::Api.new
      end
    end

    def fetch_transactions_for_address(address)
      address_full_txs = @blockcypher.address_full_txs(address)
      address_full_txs['txs'].map{|tx| convert_transactions(tx, address)}
    end

    private

    def convert_transactions(transaction, address)
      {
        txHash: transaction["hash"],
        blockHash: transaction["block_hash"],
        blockTime: DateTime.iso8601(transaction["confirmed"]),
        estimatedTxTime: DateTime.iso8601(transaction["received"]),
        estimatedTxValue: transaction['outputs'].sum{|out| out['addresses'].join.eql?(address) ? out["value"] : 0}
      }

    end
  end
end
