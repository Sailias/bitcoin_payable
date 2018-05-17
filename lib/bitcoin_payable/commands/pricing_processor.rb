module BitcoinPayable
    class PricingProcessor

      def self.perform
        new.perform
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
        uri = URI.parse("https://apiv2.bitcoinaverage.com/indices/local/ticker/BTC#{BitcoinPayable.config.currency.to_s.upcase}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri.request_uri)

        response = http.request(request)
        hash = JSON.parse(response.body)

        rate = case BitcoinPayable.config.rate_calculation
        when :daily_average 
          hash["averages"]["day"]
        when :weekly_average
          hash["averages"]["week"]
        when :monthly_average
          hash["averages"]["month"]
        else
          hash[BitcoinPayable.config.rate_calculation.to_s]
        end

        rate.to_f * 100.00
      end

      def get_currency
        #uri = URI("http://rate-exchange.appspot.com/currency?from=#{BitcoinPayable.config.currency}&to=USD")
        #rate = JSON.parse(Net::HTTP.get(uri))["rate"]

        uri = URI("http://openexchangerates.org/api/latest.json?app_id=#{BitcoinPayable.config.open_exchange_key}")
        response = JSON.parse(Net::HTTP.get(uri))
        response["rates"][BitcoinPayable.config.currency.to_s.upcase]
      end
    end
end
