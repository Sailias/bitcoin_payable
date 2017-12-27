module BitcoinPayable
  class BitcoinCalculator
    def self.convert_satoshis_to_bitcoin(satoshis)
      satoshis * 0.00000001
    end

    def self.convert_bitcoins_to_satoshis(bitcoins)
      bitcoins / 0.00000001
    end

    # NOTE: Price is in cents.
    def self.exchange_price(price, exchange_rate)
      ((price.to_f / 100) / exchange_rate.to_f).round(8)
    end
  end
end
