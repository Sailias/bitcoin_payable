module BitcoinPayable
  class BitcoinPaymentTransaction < ::ActiveRecord::Base

    belongs_to :bitcoin_payment

  end
end
