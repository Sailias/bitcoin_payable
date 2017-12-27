module BitcoinPayable
    class PricingProcessor

      def self.perform
        new.perform
      end

      def initialize
      end

      def perform
        # => Store three previous price ranges
        # => get_currency TODO: enable this again
        # => Defaulting to 1.00 for now
        rate = CurrencyConversion.create!(currency: 1.00, btc: get_btc)

        # => Loop through all unpaid payments and update them with the new price
        # => If it has been 20 mins since they have been updated
        BitcoinPayable::BitcoinPayment.where(state: ['pending', 'partial_payment']).where("updated_at < ? OR btc_amount_due = 0", 30.minutes.ago).each do |bp|
          bp.update!(btc_amount_due: bp.calculate_btc_amount_due, btc_conversion: rate.btc)
        end
      end

      def get_btc
        response = get_request("https://api.coinbase.com/v2/prices/spot\?currency\=#{BitcoinPayable.config.currency.to_s.upcase}")
        json = JSON.parse(response.body)
        json['data']['amount'].to_f
      rescue EOFError
        response = get_request("https://api.gemini.com/v1/pubticker/BTC#{BitcoinPayable.config.currency.to_s.upcase}")
        json = JSON.parse(response.body)
        json['last'].to_f
      end

      def get_currency
        #uri = URI("http://rate-exchange.appspot.com/currency?from=#{BitcoinPayable.config.currency}&to=USD")
        #rate = JSON.parse(Net::HTTP.get(uri))["rate"]

        uri = URI("http://openexchangerates.org/api/latest.json?app_id=#{BitcoinPayable.config.open_exchange_key}")
        response = JSON.parse(Net::HTTP.get(uri))

        if response['status'] && response['status'] >= 400
          raise "#{response['message']} #{response['description']}"
        end

        response["rates"][BitcoinPayable.config.currency.to_s.upcase]
      end

      private

      def get_request url
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request(request)
      end
    end
end
