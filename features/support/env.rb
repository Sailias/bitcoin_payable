ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../../spec/dummy/config/environment.rb",  __FILE__)

ENV["RAILS_ROOT"] ||= File.dirname(__FILE__) + "../../../spec/dummy"

require 'cucumber/rails'
require 'cucumber/rspec/doubles'

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  3.times do
    BitcoinPayable::CurrencyConversion.create!(
      currency: rand() * (0.99 - 0.85) + 0.85,
      btc: (rand(500.0) + 500.0) * 100
    )
  end
  @currency_conversions = BitcoinPayable::CurrencyConversion.all

  # return_values = []
  # 10.times do
  #  return_values << rand(500.0) + 500.0
  # end

  #allow_any_instance_of(BitcoinPayable::PricingProcessor).to receive(:get_btc).and_return { return_values.shift }
  #allow_any_instance_of(BitcoinPayable::PricingProcessor).to receive(:get_currency).and_return(rand() * (0.99 - 0.85) + 0.85)
end