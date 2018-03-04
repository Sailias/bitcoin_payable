#require 'bitcoin-addrgen'
require 'money-tree'
require 'state_machine'

module BitcoinPayable
  class BitcoinPayment < ::ActiveRecord::Base

    belongs_to :payable, polymorphic: true
    has_many :transactions, class_name: 'BitcoinPayable::BitcoinPaymentTransaction'

    validates :reason, presence: true
    validates :price, presence: true

    before_save :populate_currency_and_amount_due
    after_create :populate_address
    after_create :subscribe_tx_notifications, if: :webhooks_enabled

    state_machine :state, initial: :pending do
      state :pending
      state :partial_payment
      state :paid_in_full     # Merchans watch out! it can be rolled back
      state :comfirmed        # Inpossible to revert payment
      state :comped
      state :canceled

      event :paid do
        transition [:pending, :partial_payment] => :paid_in_full
      end

      event :secure_payment do
        transition :paid_in_full => :comfirmed
      end

      event :partially_paid do
        transition :pending => :partial_payment
      end

      event :comp do
        transition [:pending, :partial_payment] => :comped
      end

      event :cancel do
        transition all => :canceled
      end

      event :nothing_paid do
        transition [:paid_in_full, :partial_payment] => :pending
      end

      after_transition :on => :paid,           :do => :notify_payable_paid
      after_transition :on => :secure_payment, :do => :notify_payable_paid_and_comfirmed
      after_transition :on => :secure_payment, :do => :desubscribe_tx_notifications if BitcoinPayable.config.allowwebhooks
      after_transition :on => :comp,           :do => [:notify_payable_paid_and_comfirmed, :notify_payable_paid]
      after_transition :on => :nothing_paid,   :do => :notify_payable_rollback

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

    def check_if_paid
      fiat_paid = currency_amount_paid
      if fiat_paid >= price
        paid
        check_if_payment_secure
      elsif fiat_paid > 0
        partially_paid
      else
        nothing_paid
      end
    end

    def check_if_payment_secure
      secure_payment if transactions.all?{|tx| tx.secure?}
    end

    def method_missing(m, *args)
      method = m.to_s
      if method.start_with?('notify_payable_')
        attribute = method[15..-1]
        if payable.respond_to?("bitcoin_payment_#{attribute}")
          payable.send("bitcoin_payment_#{attribute}")
        end

      elsif method.end_with?('_tx_notifications')
        sub_or_desub = method[0..-26]
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
