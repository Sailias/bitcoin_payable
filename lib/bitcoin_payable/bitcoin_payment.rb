#require 'bitcoin-addrgen'
require 'money-tree'
require 'state_machine'

module BitcoinPayable
  class BitcoinPayment < ::ActiveRecord::Base

    belongs_to :payable, polymorphic: true
    has_many :transactions, class_name: BitcoinPayable::BitcoinPaymentTransaction

    validates :reason, presence: true
    validates :price, presence: true

    before_create :populate_currency_and_amount_due
    after_create :populate_address

    state_machine :state, initial: :pending do
      state :pending
      state :partial_payment
      state :paid_in_full
      state :comped

      event :paid do
        transition [:pending, :partial_payment] => :paid_in_full
      end

      after_transition :on => :paid, :do => :notify_payable

      event :partially_paid do
        transition :pending => :partial_payment
      end

      event :comp do
        transition :pending => :comped
      end

      after_transition :on => :comp, :do => :notify_payable
    end

    def currency_amount_paid
      # => Round to 0 decimal places so there aren't any partial cents
      self.transactions.inject(0) { |sum, tx| sum + (BitcoinPayable::BitcoinCalculator.convert_satoshis_to_bitcoin(tx.estimated_value) * tx.btc_conversion) }.round(0)
    end

    def currency_amount_due
      self.price - currency_amount_paid
    end

    def calculate_btc_amount_due(btc_rate = nil)
      btc_rate ||= BitcoinPayable::CurrencyConversion.last.btc
      BitcoinPayable::BitcoinCalculator.exchange_price currency_amount_due, btc_rate
    end

    private

    def populate_currency_and_amount_due
      self.currency ||= BitcoinPayable.config.currency
      self.btc_amount_due = calculate_btc_amount_due
      self.btc_conversion = CurrencyConversion.last.btc
    end

    def populate_address
      self.update(address: Address.create(self.id))
    end

    def notify_payable
      if self.payable.respond_to?(:bitcoin_payment_paid)
        self.payable.bitcoin_payment_paid
      end
    end

  end
end