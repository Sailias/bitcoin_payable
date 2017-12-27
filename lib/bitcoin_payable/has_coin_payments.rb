module BitcoinPayable
  module Model
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def has_coin_payments(options = {})
        has_many :coin_payments, -> { order(:id) },
          class_name: 'BitcoinPayable::CoinPayment',
          as: 'payable'
      end
    end
  end
end
