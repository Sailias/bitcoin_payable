#require 'bitcoin-addrgen'
require 'money-tree'
require 'aasm'

module BitcoinPayable
  class BitcoinPayment < ::ActiveRecord::Base
    include AASM
    belongs_to :payable, polymorphic: true
    has_many :transactions, class_name: "BitcoinPayable::BitcoinPaymentTransaction"

    validates :reason, presence: true
    validates :price, presence: true

    before_create :populate_currency_and_amount_due
    after_create :populate_address
    after_create :subscribe_tx_notifications, if: :webhooks_enabled

    aasm :column => 'state' do
      state :pending, :initial => true
      state :partial_payment, :paid_in_full, :comped

      event :paid do
        after do
          notify_payable
          desubscribe_tx_notifications
        end
        transitions :from => [:pending, :partial_payment], :to => :paid_in_full
      end

      event :partially_paid do
        transitions :from => :pending, :to => :partial_payment
      end

      event :comp do
        after do
          notify_payable
        end
        transitions :from => [:pending, :partial_payment], :to => :comped
      end


    end

    def currency_amount_paid
      # => Round to 0 decimal places so there aren't any partial cents
      self.transactions.inject(0) { |sum, tx| sum + (BitcoinPayable::BitcoinCalculator.convert_satoshis_to_bitcoin(tx.estimated_value) * tx.btc_conversion) }.round(0)
    end

    def currency_amount_due
      self.price - currency_amount_paid
    end

    def calculate_btc_amount_due
      btc_rate = BitcoinPayable::CurrencyConversion.last.btc
      BitcoinPayable::BitcoinCalculator.exchange_price currency_amount_due, btc_rate
    end

    def update_after_new_transactions
      update_attributes(btc_amount_due: calculate_btc_amount_due,
                        btc_conversion: BitcoinPayable::CurrencyConversion.last.btc)
      check_if_paid
    end

    def check_if_paid
      fiat_paid = currency_amount_paid
      if fiat_paid >= price
        paid!
      elsif fiat_paid > 0
        partially_paid!
      end
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

    def method_missing(m, *args)
      method = m.to_s
      if method.end_with?('_tx_notifications')
        adapter = BitcoinPayable::Adapters::Base.fetch_adapter
        adapter.send(method, address)
      else
        super
      end
    end

    def webhooks_enabled
      BitcoinPayable.config.allowwebhooks
    end

  end
end
