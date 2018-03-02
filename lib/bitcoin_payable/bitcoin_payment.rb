#require 'bitcoin-addrgen'
require 'money-tree'
require 'state_machine'

module BitcoinPayable
  class BitcoinPayment < ::ActiveRecord::Base

    belongs_to :payable, polymorphic: true
    has_many :transactions, class_name: 'BitcoinPayable::BitcoinPaymentTransaction'

    validates :reason, presence: true
    validates :price, presence: true

    rails3?{ attr_accessible :reason, :price, :address, :btc_amount_due,
                    :btc_conversion, :currency, :payable_type }
                    
    before_save :populate_currency_and_amount_due
    after_create :populate_address
    after_create :subscribe_to_notifications_in_pool, if: :webhooks_and_zero_conf

    state_machine :state, initial: :pending do
      state :pending
      state :partial_payment
      state :paid_in_full
      state :comped
      state :canceled

      event :paid do
        transition [:pending, :partial_payment] => :paid_in_full
      end

      after_transition :on => :paid, :do => :notify_payable

      event :partially_paid do
        transition :pending => :partial_payment
      end

      event :comp do
        transition [:pending, :partial_payment] => :comped
      end
      after_transition :on => :comp, :do => :notify_payable

      event :cancel do
        transition all => :canceled
      end

      event :nothing_paid do
        transition [:paid_in_full, :partial_payment] => :pending
      end
      after_transition :on => :nothing_paid, :do => :notify_rollback_payable

    end

    def currency_amount_paid
      self.transactions.where('confirmations != ?', -1).inject(0) do |sum, tx|
        sum + (BitcoinPayable::BitcoinCalculator.convert_satoshis_to_bitcoin(tx.estimated_value) * tx.btc_conversion)
      end.round(0)
    end

    def currency_amount_due
      self.price - currency_amount_paid
    end

    def calculate_btc_amount_due
      btc_rate = BitcoinPayable::CurrencyConversion.obtain(crypto: self.crypto, currency: self.currency).last.rate
      BitcoinPayable::BitcoinCalculator.exchange_price currency_amount_due, btc_rate
    end

    def update_after_new_transactions
      update_attributes(btc_amount_due: calculate_btc_amount_due,
                        btc_conversion: BitcoinPayable::CurrencyConversion.obtain(crypto: self.crypto,
                                                                                  currency: self.currency).last.rate)
      check_if_paid
    end

    private
    def populate_currency_and_amount_due
      self.currency ||= BitcoinPayable.config.currency
      self.crypto ||=  BitcoinPayable.config.crypto
      self.btc_amount_due = calculate_btc_amount_due
      self.btc_conversion = BitcoinPayable::CurrencyConversion.obtain(crypto: self.crypto, currency: self.currency).last.rate
    end

    def populate_address
      update_attributes(address: Address.create(self.id))
    end

    def notify_payable
      if self.payable.respond_to?(:bitcoin_payment_paid)
        self.payable.bitcoin_payment_paid
      end
    end

    def subscribe_to_notifications_in_pool
      adapter = BitcoinPayable::Adapters::Base.fetch_adapter
      adapter.subscribe_notify_transaction_in_mempool(address)
    end

    def check_if_paid
      fiat_paid = currency_amount_paid
      if fiat_paid >= price
        paid
      elsif fiat_paid > 0
        partially_paid
      else
        nothing_paid
      end
    end

    def notify_rollback_payable
      if self.payable.respond_to?(:bitcoin_payment_rollback)
        self.payable.bitcoin_payment_rollback
      end
    end

    def webhooks_and_zero_conf
      BitcoinPayable.config.zero_tx && BitcoinPayable.config.allowwebhooks
    end
  end
end
