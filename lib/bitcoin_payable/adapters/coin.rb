module BitcoinPayable
  module Adapters
    protected

    class Coin
      # Implement these in a subclass:

      # Must return an integer representing the smallest unit of the currency.
      # def self.convert_main_to_subunit(main)
      # end

      # def self.convert_subunit_to_main(subunit)
      # end

      # def self.exchange_price(price, exchange_rate)
      # end

      # def self.get_transactions_for(address)
      # end

      # def self.create_address(id)
      # end

      protected

      def self.get_rate(coin_symbol)
        amount = begin
          response = get_request("https://api.coinbase.com/v2/prices/#{coin_symbol}-#{BitcoinPayable.configuration.currency.to_s.upcase}/spot")
          JSON.parse(response.body)['data']['amount'].to_f
        rescue EOFError
          response = get_request("https://api.gemini.com/v1/pubticker/#{coin_symbol}#{BitcoinPayable.configuration.currency.to_s.upcase}")
          JSON.parse(response.body)['last'].to_f
        end
        convert_main_to_subunit(amount)
      end

      private

      def self.get_request(url)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request(request)
      end
    end
  end
end
