module BitcoinPayable::Adapters
  class BlockchainInfoAdapter < Base

    # TODO: Support Bitcoin Cash when it's ready at Blockcypher
    
    def initialize
      if BitcoinPayable.config.testnet
        raise "Testnet not supported"
      else
        @url = "https://blockchain.info"
      end
    end

    def fetch_transactions_for_address(address)
      url = "#{@url}/rawaddr/#{address}"
      url += "?api_code=" + BitcoinPayable.config.adapter_api_key if BitcoinPayable.config.adapter_api_key
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      hash = JSON.parse(response.body)
      hash['txs'].map{|tx| convert_transactions(tx, address)}
    end

    private

    def latest_block
      url = "#{@url}/latestblock"
      url += "?api_code=" + BitcoinPayable.config.adapter_api_key if BitcoinPayable.config.adapter_api_key
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      JSON.parse(response.body)
    end

    def convert_transactions(transaction, address)
      confirmations = latest_block["height"] - transaction["block_height"] + 1

      {
        txHash: transaction["hash"],
        blockHash: nil,  # Not supported
        blockTime: nil,  # Not supported
        estimatedTxTime: transaction["time"],
        estimatedTxValue: transaction['out'].sum{|out| out['addr'].eql?(address) ? out["value"] : 0},
        confirmations: confirmations
      }
    end

  end
end
