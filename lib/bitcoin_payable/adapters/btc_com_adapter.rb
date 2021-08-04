require 'blockcypher'
module BitcoinPayable::Adapters
  class BtcComAdapter < Base

    def initialize
      if BitcoinPayable.config.testnet
        raise "Testnet not supported"
      else
        @url = "https://chain.api.btc.com"
      end
    end

    def fetch_transactions_for_address(address)
      url = "#{@url}/v3/address/#{address}/tx"
      url += "?api_key=" + BitcoinPayable.config.adapter_api_key if BitcoinPayable.config.adapter_api_key
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      hash = JSON.parse(response.body)
      if hash["data"] && hash['data']["list"]
        hash['data']["list"].map{|tx| convert_transactions(tx, address)}
      else
        []
      end
    end

    private

    def convert_transactions(transaction, address)
      {
        txHash: transaction["hash"],
        blockHash: transaction["block_hash"],
        blockTime: transaction["block_time"],
        estimatedTxTime: transaction["created_at"],
        estimatedTxValue: transaction["balance_diff"],
        confirmations: transaction["confirmations"]
      }
    end
  end
end
