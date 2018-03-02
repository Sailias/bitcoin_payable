module BitcoinPayable
    class PricingProcessor

      def self.perform(args=nil)
        new(args).perform
      end

      def self.update_rates_for_all_pairs
        available_fiats.each do |fiat|
          available_cryptos.each do |crypto|
            PricingProcessor.perform(crypto:crypto, currency: fiat)
            clean_old_rates(crypto:crypto, currency: fiat)
          end
        end
      end

      def initialize(args=nil)
        args = {} if args.nil?
        @crypto = (args[:crypto] || BitcoinPayable.config.crypto).downcase.to_sym
        @currency = (args[:currency] || BitcoinPayable.config.currency).downcase.to_sym
      end

      def perform
        conversion = CurrencyConversion.create!(currency: @currency, crypto: @crypto, rate: get_rate)
        # => Loop through all unpaid payments and update them with the new price
        # => If it has been 20 mins since they have been updated
        BitcoinPayable::BitcoinPayment.where(state: ['pending', 'partial_payment'],
                                             crypto: @crypto,
                                             currency: @currency)
                                            .where("updated_at < ? OR btc_amount_due = 0", 30.minutes.ago).each do |bp|
                                              bp.update_attributes(btc_amount_due: bp.calculate_btc_amount_due,
                                                                   btc_conversion: conversion.rate)
                                            end
        return conversion
      end

      def get_rate
        uri = URI.parse("https://apiv2.bitcoinaverage.com/indices/global/ticker/#{@crypto.to_s.upcase}#{@currency.to_s.upcase}")
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

        rate_in_cents = rate.to_f * 100.00
      end

      private
      def self.clean_old_rates(args={})
        BitcoinPayable::CurrencyConversion.where('crypto = ? AND currency = ? AND created_at < ?',
                                                  args[:crypto],
                                                  args[:currency],
                                                  5.days.ago)
                                          .delete_all

      end

      def self.available_cryptos
        cryptos_in_payments = BitcoinPayable::BitcoinPayment.pluck(:crypto)
        cryptos_in_exchange_rate = BitcoinPayable::CurrencyConversion.pluck(:crypto)
        cryptos = cryptos_in_payments + cryptos_in_exchange_rate
        cryptos.uniq
      end

      def self.available_fiats
        fiats_in_payments = BitcoinPayable::BitcoinPayment.pluck(:currency)
        fiats_in_exchange_rate = BitcoinPayable::CurrencyConversion.pluck(:currency)
        fiats = fiats_in_payments + fiats_in_exchange_rate
        fiats.uniq
      end
    end
end
