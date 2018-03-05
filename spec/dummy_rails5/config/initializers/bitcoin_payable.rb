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
