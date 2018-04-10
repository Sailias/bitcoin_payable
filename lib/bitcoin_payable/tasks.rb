require 'rake'
require 'bitcoin_payable/commands/pricing_processor'
require 'bitcoin_payable/commands/payment_processor'

namespace :bitcoin_payable do

  desc "Process the prices and update the payments"
  task :process_prices => :environment do
    BitcoinPayable::PricingProcessor.update_rates_for_all_pairs
  end

  desc "Process payments"
  task :process_payments => :environment do
    BitcoinPayable::PaymentProcessor.perform
  end

  desc "Clean old crytocurrency rates.
  \r    You can specify the age, in days, of the rates you would like to clean."
  task :clean_old_rates, [:days_old] => :environment do |t, args|
    BitcoinPayable::PricingProcessor.clean_up_rates(args[:days_old])
  end

end
