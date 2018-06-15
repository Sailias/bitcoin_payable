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
    after_create :subscribe_to_address_push_notifications, if: :webhooks_enabled

    aasm :column => 'state' do
      state :pending, :initial => true
      state :partial_payment, :paid_in_full, :comped, :confirmed

      after_all_transitions :notify_status_changed

      event :confirm do
        after do
          unsubscribe_address_push_notifications if webhooks_enabled
        end
        transitions :from => [:pending, :paid_in_full, :partial_payment], :to => :confirmed
      end

      event :paid do
        after do
          notify_payable
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
      btc_rate = BitcoinPayable::CurrencyConversion.last_rate_for self.currency
      BitcoinPayable::BitcoinCalculator.exchange_price currency_amount_due, btc_rate
    end

    def secure?
      return true if transactions.all?{|tx| tx.secure?}
      return false
    end

    private

    def populate_currency_and_amount_due
      self.currency ||= BitcoinPayable.config.currency
      self.btc_conversion = CurrencyConversion.last_rate_for self.currency
      self.btc_amount_due = calculate_btc_amount_due

    end

    def populate_address
      self.update_attributes(address: Address.create(self.id))
    end

    def notify_status_changed
      if self.payable.respond_to?(:bitcoin_payment_status_changed)
        self.payable.bitcoin_payment_status_changed(aasm.from_state, aasm.to_state)
      end
    end

    def notify_payable
      if self.payable.respond_to?(:bitcoin_payment_paid)
        self.payable.bitcoin_payment_paid
      end
    end

    # Subscribe to a push notification that will alert us via a webhook when a transaction is received for this address
    def subscribe_to_address_push_notifications
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      adapter.subscribe_to_address_push_notifications(self)
    end

    def unsubscribe_address_push_notifications
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      adapter.unsubscribe_to_address_push_notifications(self)
    end

    def webhooks_enabled
      BitcoinPayable.config.allowwebhooks
    end

  end
end
