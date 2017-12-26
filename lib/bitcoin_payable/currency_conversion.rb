module BitcoinPayable
  class CurrencyConversion < ::ActiveRecord::Base
    validates :price, presence: true

    # TODO: Duplicated in `CoinPayment`.
    enum coin_type: %i[
      btc
      eth
    ]
  end
end
