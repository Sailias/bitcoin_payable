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

      event :paid do
        transition [:pending, :partial_payment] => :paid_in_full
      end

      after_transition :on => :paid, :do => :notify_payable

      event :partially_paid do
        transition :pending => :partial_payment
      end
    end

    def currency_amount_paid
      self.transactions.inject(0) { |sum, tx| sum + (BitcoinPayable::BitcoinCalculator.convert_satoshis_to_bitcoin(tx.estimated_value) * tx.btc_conversion) }.round(2)
    end

    def currency_amount_due
      self.price - currency_amount_paid
    end

    def calculate_btc_amount_due
      btc_rate = BitcoinPayable::CurrencyConversion.last.btc
      BitcoinPayable::BitcoinCalculator.exchange_price currency_amount_due, btc_rate
    end

    private

    def populate_currency_and_amount_due
      self.currency ||= BitcoinPayable.config.currency
      self.btc_amount_due = calculate_btc_amount_due
    end

    def populate_address
      #BitcoinAddrgen.generate_public_address(BitcoinPayable.config.master_public_key, self.id)
      config = {
        seed_hex: BitcoinPayable.config.master_seed
      }
      config.merge!(network: :bitcoin_testnet) if BitcoinPayable.config.testnet
      master = MoneyTree::Master.new config
      node = master.node_for_path "m/0/#{self.id}"
      self.update(address: node.to_address)
    end

    def notify_payable
      if self.payable.respond_to?(:bitcoin_payment_paid)
        self.payable.bitcoin_payment_paid
      end
    end

  end
end