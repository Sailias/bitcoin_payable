module BitcoinPayable
  module Model

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def has_bitcoin_payments(options = {})
        has_many :bitcoin_payments, -> {order(:id)}, class_name: BitcoinPayable::BitcoinPayment, as: 'payable'
      end

    end
  end
end