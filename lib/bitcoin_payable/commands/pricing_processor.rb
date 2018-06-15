module BitcoinPayable
    class PricingProcessor

      class << self
        def perform
          new.perform
        end

        def update_rates_for_all_pairs
          known_currencies_in_app.each do |currency|
              PricingProcessor.new(currency: currency).perform
          end
        end

        def clean_up_rates(days_old=5)
          BitcoinPayable::CurrencyConversion.where('created_at < ?',days_old.to_i.days.ago).delete_all
        end

        private
        def known_currencies_in_app
          fiats_in_payments = BitcoinPayable::BitcoinPayment.pluck(:currency)
          fiats_in_exchange_rate = BitcoinPayable::CurrencyConversion.pluck(:currency)
          known_fiats = fiats_in_payments + fiats_in_exchange_rate
          known_fiats.uniq
        end
      end

      def initialize(args={})
        @currency = (args[:currency] || BitcoinPayable.config.currency).downcase.to_sym
      end

      def perform
        rate = CurrencyConversion.create!(currency: @currency, btc: get_btc)

        # => Loop through all unpaid payments for a certain currency
        # => and update them with the new price
        # => If it has been 20 mins since they have been updated
        BitcoinPayable::BitcoinPayment
          .where(state: ['pending', 'partial_payment'])
          .where(currency: @currency)
          .where("updated_at < ? OR btc_amount_due = 0", 30.minutes.ago).each do |bp|
            bp.update_attributes!(btc_amount_due: bp.calculate_btc_amount_due, btc_conversion: rate.btc)
          end
      end

      def get_btc
        uri = URI.parse("https://apiv2.bitcoinaverage.com/indices/local/ticker/"\
                        "#{BitcoinPayable.config.crypto.to_s.upcase}#{BitcoinPayable.config.currency.to_s.upcase}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri.request_uri)

        response = http.request(request)
        hash = JSON.parse(response.body)

        prices = {
          last: hash["last"],
          high: hash["high"],
          low: hash["low"],
          daily_average: hash["averages"]["day"],
          weekly_average: hash["averages"]["week"],
          monthly_average: hash["averages"]["month"]
        }

        rate = prices[BitcoinPayable.config.rate_calculation] || prices[:daily_average]
        rate.to_f * 100.00
      end

      # def get_currency
      #   #uri = URI("http://rate-exchange.appspot.com/currency?from=#{BitcoinPayable.config.currency}&to=USD")
      #   #rate = JSON.parse(Net::HTTP.get(uri))["rate"]
      #
      #   uri = URI("http://openexchangerates.org/api/latest.json?app_id=#{BitcoinPayable.config.open_exchange_key}")
      #   response = JSON.parse(Net::HTTP.get(uri))
      #   response["rates"][BitcoinPayable.config.currency.to_s.upcase]
      # end
    end
end
