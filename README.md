# BitcoinPayable

A rails gem that enables any model to have bitcoin payments.
The polymorphic table bitcoin_payments creates payments with unique addresses based on a BIP32 deterministic seed using https://github.com/wink/money-tree
and uses the (https://helloblock.io OR https://blockchain.info/) API to check for payments.

Payments have 4 states:  `pending`, `partial_payment`, `paid_in_full`, `comped`

No private keys needed, No bitcoind blockchain indexing on new servers, just address and payments.

Donations appreciated

`142WJW4Zzc9iV7uFdbei8Unpe8WcLhUgmE`

## Rails 5.1

[Support for Rails 5.1](https://github.com/Sailias/bitcoin_payable/tree/releases/rails-5.1)

## Other crypto currencies

[Cryptocoin Payable](https://github.com/Sailias/cryptocoin_payable)

## Installation

Add this line to your application's Gemfile:  (I might be too lazy to update RubyGems all the time)

    gem 'bitcoin_payable', git: 'https://github.com/Sailias/bitcoin_payable', branch: 'master'

And then execute:

    $ bundle

    $ rails g bitcoin_payable:install

    $ bundle exec rake db:migrate

Or install it yourself as:

    $ gem install bitcoin_payable

## Usage

### Configuration

config/initializers/bitcoin_payable.rb

  BitcoinPayable.config do |config|

    config.currency = :usd    # Default currency

    # Webhooks
    # Only available for blocktrail adapter
    config.allowwebhooks = true
    config.auto_calculate_rate_every = 5.hours # Only when webhooks are enabled
    config.webhook_domain = "domain.com"       # No subdomains or IPs supported
    config.webhook_port = "3000"               # Let empty if it's not needed

    config.node_path = "m/0/"
    config.master_public_key = "your xpub master public key here"

    config.testnet = true
    config.adapter = 'blocktrail' # Use blocktrail, blockchain_info or blockcypher
  end


* In order to use the bitcoin network and issue real addresses, BitcoinPayable.config.testnet must be set to false *

    BitcoinPayable.config.testnet = false

#### Blocktrail Adapter

If you use `config.adapter = 'blocktrail'` * The only one supporting webhooks* you'll need to set the following environment variables:

    # Basic authentification for your webhooks
    ENV['BITCOINPAYABLE_WEBHOOK_NAME']= "key"
    ENV['BITCOINPAYABLE_WEBHOOK_PASS']= "key"

    # API keys provided by Blocktrail.com
    ENV['BLOCKTRAIL_API_KEY']= "key"
    ENV['BLOCKTRAIL_API_SECRET']= "secret"

You can obtain your API keys at https://www.blocktrail.com/dev/login
#### Node Path

The derivation path for the node that will be creating your addresses

#### Master Public Key

A BIP32 MPK in "Extended Key" format.

Public net starts with: xpub
Testnet starts with: tpub

### Adding it to your model

    class Product < ActiveRecord::Base
      has_bitcoin_payments
    end

### Creating a payment from your application

    def create_payment(amount_in_cents)
      self.bitcoin_payments.create!(reason: 'sale', price: amount_in_cents)
    end

### Update payments with the current price of BTC based on your currency

BitcoinPayable also supports local currency conversions and BTC exchange rates.

The `process_prices` rake task connects to api.bitcoinaverage.com to get the 24 hour weighted average of BTC for your specified currency.
It then updates all payments that havent received an update in the last 30 minutes with the new value owing in BTC.
This *honors* the price of a payment for 30 minutes at a time.

`rake bitcoin_payable:process_prices`

### Processing payments

All payments are calculated against the dollar amount of the payment.  So a `bitcoin_payment` for $49.99 will have it's value calculated in BTC.
It will stay at that price for 30 minutes.  When a payment is made, a transaction is created that stores the BTC in satoshis paid, and the exchange rate is was paid at.
This is very valuable for accounting later.  (capital gains of all payments received)

If a partial payment is made, the BTC value is recalculated for the remaining *dollar* amount with the latest exchange rate.
This means that if someone pays 0.01 for a 0.5 payment, that 0.01 is converted into dollars at the time of processing and the
remaining amount is calculated in dollars and the remaining amount in BTC is issued.  (If BTC bombs, that value could be greater than 0.5 now)

This prevents people from gaming the payments by paying very little BTC in hopes the price will rise.
Payments are not recalculated based on the current value of BTC, but in dollars.

To run the payment processor:

`rake bitcoin_payable:process_payments`

### Notify your application when a payment is made

Use the `bitcoin_payment_paid` method

    def Product < ActiveRecord::Base
      has_bitcoin_payments

      def create_payment(amount_in_cents)
        self.bitcoin_payments.create!(reason: 'sale', price: amount_in_cents)
      end

      def bitcoin_payment_paid
        self.ship!
      end
    end

### Comp a payment

This will bypass the payment, set the state to comped and call back to your app that the payment has been processed.

`@bitcoin_payment.comp`

### View all the transactions in the payment

    bitcoin_payment = @product.bitcoin_payments.first
    bitcoin_payment.transactions.each do |transaction|
      puts transaction.block_hash
      puts transaction.block_time

      puts transaction.transaction_hash

      puts transaction.estimated_value
      puts transaction.estimated_time

      puts transaction.btc_conversion
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
