module BitcoinPayable
  class PricingProcessor
    def self.perform
      new.perform
    end

    def perform
      # Loop through all unpaid payments and update them with the new price if
      # it has been 30 mins since they have been updated.
      CoinPayment.where(state: [:pending, :partial_payment]).where("updated_at < ? OR btc_amount_due = 0", 30.minutes.ago).each do |payment|
        # TODO: Store three previous price ranges, defaulting to 100 for now.
        conversion = CurrencyConversion.create!(
          currency: 100,
          price: Adapters.for(payment.coin_type).get_rate
        )
        payment.update!(
          coin_amount_due: payment.calculate_coin_amount_due,
          coin_conversion: rate.price
        )
      end
    end
  end
end
