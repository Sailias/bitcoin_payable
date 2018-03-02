# BitcoinPayable

Accept easily **Bitcoin** or **Bitcoin Cash** payments in your Rails application

BitcoinPayable gem enables any Rails ActiveRecord model to have bitcoin payments.
The polymorphic table bitcoin_payments creates payments with unique addresses based on a BIP32 deterministic seed using [Money Tree](https://github.com/wink/money-tree) gem
and uses the [Blocktrail.com API](https://www.blocktrail.com/api/docs) to check for payments.

Multicurrency support. Accept many fiat currencies.

Webhooks implementation so that your app gets notified.

Payments have 4 states:  `pending`, `partial_payment`, `paid_in_full`, `canceled` and `comped`

No private keys needed, no need to run bitcoind blockchain indexing on new servers, just address and payments.

Donations appreciated

Bitcoin Address: `142WJW4Zzc9iV7uFdbei8Unpe8WcLhUgmE`

## Rails 5.1

[Support for Rails 5.1](https://github.com/Sailias/bitcoin_payable/tree/releases/rails-5.1)

## Rails 3.2

[Compatible with with Rails 3](http://guides.rubyonrails.org/v3.2.21/)

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
      # :bch for Bitcoin Cash and :BTC for Bitcoin
      config.crypto = :bch

      config.currency = :usd # Default currency

      # This will consider payments in the mempool as paid
      config.zero_tx = true

      # A payment will be considered paid afther this confirmations
      # set to 1,2,3,4,5 or 6
      config.confirmations = 3

      # webhooks
      config.allowwebhooks = true
      config.auto_calculate_rate_every = 5.hours # Only when webhooks are enabled
      config.webhook_domain = "domain.com" # No subdomains or IPs supported
      config.webhook_port = "3000" # Let empty if it's not needed

      # The rate for Bitcoin you'll be using to calculate prices
      # :last               The last market's price
      # :high               Today's highest price
      # :low                Today's highest price
      # :daily_average      The daily average price
      # :weekly_average     The weekly average price
      # :monthly_average    The monthly average price
      config.rate_calculation = :last

      config.node_path = "m/0/"
      config.master_public_key = "your xpub master public key here"

      config.testnet = true
      config.adapter = 'blocktrail' # the only abailable as for version 0.8.0
    end



* In order to use the bitcoin network and issue real addresses, BitcoinPayable.config.testnet must be set to false *

    `config.testnet = false`

* If you set config.zero_tx to true, a transaction with 0 confirmations will be understood
as secure and the payment set as paid. If the transaction doesn't reach config.confirmations
the payment will be rolled back

#### Blocktrail Adapter

If you use `config.adapter = 'blocktrail'` *# the only abailable as for version 0.8.0* you'll need to sef the following enviroment variables:

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
      self.bitcoin_payments.create!(reason: 'sale', price: amount_in_cents, currency: :usd)
    end

* if `:currency` is not set, the default currency set at `config.currency` will be picked
* For Rails 3 you might need to include `payable_type: self.class.name`

### Update payments with the current price of BTC or BCH based on your currency

BitcoinPayable also supports local currency conversions and BTC or BCH exchange rates.

The `process_prices` rake task connects to api.bitcoinaverage.com to get the 24 hour weighted average of BTC or BCH for your specified currency.
It then updates all payments that haven't received an update in the last 30 minutes with the new value owing in BTC or BCH.
This *honors* the price of a payment for 30 minutes at a time.

* Update the exchange rate of the crypto and fiat set to default `rake bitcoin_payable:process_prices`

* Update the BCH/USD rate `rake bitcoin_payable:process_prices["BCH","USD"]`
* Update the BTC/EUR rate `rake bitcoin_payable:process_prices["BCH","USD"]`

* You can run `rake bitcoin_payable:update_rates_for_all_pairs` and the gem will check every fiat and crypto that is used in your payments and conversion history and will update to the currency rate, cleaning the old rates.

#### Bootstraping a new currency
The gem will automatically create the conversion rate for a currency if it doesn't exist in the conversion table at the time of creating a payment. You can add a payment for any currency at any time without worrying of not having the conversion created.

### Processing payments

All payments are calculated against the currency amount set for the payment.  So a `bitcoin_payment` for $49.99 will have it's value calculated in BTC or BCH.
It will stay at that price for 30 minutes.  When a payment is made, a transaction is created that stores the BTC or BCH in Satoshis paid, and the exchange rate is was paid at.
This is very valuable for accounting later.  (capital gains of all payments received)

If a partial payment is made, the BTC or BCH value is recalculated for the remaining *fiat money* amount with the latest exchange rate.
This means that if someone pays 0.01 for a 0.5 payment, that 0.01 is converted into dollars at the time of processing and the
remaining amount is calculated in dollars and the remaining amount in BTC or BCH is issued.  (If BTC or BCH bombs, that value could be greater than 0.5 now)

This prevents people from gaming the payments by paying very little BTC or BCH in hopes the price will rise.
Payments are not recalculated based on the current value of BTC or BCH, but in dollars.

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

## Webhooks

If you set `config.allowwebhooks = true` this gem will enable two webhook addresses in your app.
You'll need to specify `config.webhook_port` and `config.webhook_domain`.

The gem will install the routes:
* bitcoin/notifytransaction *Only if config.zero_tx is set to true*
* bitcoin/lastblock

**This gem will subscribe all the webhooks for you so you don't need to set anything on the server offering the webhooks.**

#### `bitcoin/notifytransaction`
 This webhook endpoint will receive and store transactions that have zero confirmations, that is, that are still in the mempool.

#### `last_block`
This webhook will be called every new block and will be used to process the pending payments and update the currency rate.

When the webhooks are enabled here is no need to process the payments with `rake bitcoin_payable:process_payments` or `rake bitcoin_payable:update_rates_for_all_pairs`. Aditionally by calling this webhook the rates will be updated ever `config.auto_calculate_rate_every`




## Zero confirmations transactions
Set `config.zero_tx=true` and a payment will be considered paid even if the asociated transaction has zero confirmations, that is, the transaction is in the mempool. If the transaction finally doesn't reach `config.confirmations` the payment will be rolled back.

This will give your user an instant experience. This is particular secure if used in the Bitcoin Cash network as every transaction in the mempool will enter the next block since Bitcoin Cash is set to scale increasing the block size to fit all transactions in the network.


## Notify your application when a payment is Rolled Back
A transaction won't be considered solid or secure and the payment won't be set as paid until a transaction reaches `config.confirmations`. If you decided to set `config.zero_tx=true` your model will be notified as payment received even if the transaction doesn't have any confirmation. If for a reason such a double spend the transaction that made the payment to be set as paid doesn't reach the desired level of security `config.confirmations` your model will be notified and the payment set as `:pending`.

Use the `bitcoin_payment_rollback` method in your model

    def Product < ActiveRecord::Base
      def bitcoin_payment_rollback
        self.cancel_payment!
      end
    end

Use this feature to give your user a nice experience while at the same time receiving secure payments. Keep in mind every confirmation takes around 10 minutes so your model may be notified instantly when a zero transaction is received while the roll back feature can take up to 60 minutes to kick in. If for example you need to ship your items right after receiving a payment you need to consider your model might be rolled back after you shipped the item out. Zero confirmation transactions can be secure for small payments *($100 to $1000)* specially in Bitcoin Cash as every transaction in the mempool will enter the next block and there is no way to replace a transaction by fee such as in Bitcoin.

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

      puts transaction.BTC or BCH_conversion
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
