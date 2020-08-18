module BitcoinPayable::Adapters
  class BitcoindAdapter < Base

    def initialize
      if BitcoinPayable.config.testnet
        raise "Testnet not supported"
      else
        @uri = URI.parse(BitcoinPayable.config.adapter_url)
      end
    end

    def fetch_transactions_for_address(address)
      post_body = { 'method' => 'query', 'params' => address, 'id' => 'jsonrpc' }.to_json
      http = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Post.new(@uri.request_uri)
      request.basic_auth @uri.user, @uri.password
      request.content_type = 'application/json'
      request.body = post_body
      response = http.request(request).body
      puts response.inspect
    end

    private

    def convert_transactions(transaction, address)
      {
        txHash: transaction["hash"],
        blockHash: transaction["block_hash"],
        blockTime: transaction["block_time"],
        estimatedTxTime: transaction["created_at"],
        estimatedTxValue: transaction['outputs'].sum{|out| out['addresses'].join.eql?(address) ? out["value"] : 0},
        confirmations: transaction["confirmations"]
      }
    end

  end
end

