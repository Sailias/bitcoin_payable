require 'rake'
require 'bitcoin_payable/commands/pricing_processor'
require 'bitcoin_payable/commands/payment_processor'

namespace :bitcoin_payable do

  desc "Process the prices and update the payments. Default will be used if no parameters given"
  task :process_prices, [:crypto, :currency] => :environment do |t, args|
    BitcoinPayable::PricingProcessor.perform(crypto: args[:crypto], currency: args[:currency])
  end

  desc "Process the prices and update the payments for all crypro and currency pairs available"
  task :update_rates_for_all_pairs => :environment do
    BitcoinPayable::CurrencyConversion.update_rates_for_all_pairs
  end

  desc "Fetch transactions from blockchain and process payments"
  task :process_payments => :environment do
    BitcoinPayable::PaymentProcessor.perform
  end
end
