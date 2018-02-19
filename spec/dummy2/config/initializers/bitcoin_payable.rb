BitcoinPayable.config do |config|
  config.currency = :usd # Default currency
  # :bch for Bitcoin Cash and :btc for Bitcoin
  config.crypto = :bch

  # This will consider payments in the mempool as paid
  config.zero_tx = true

  # A payment will be considered paid afther this confirmations
  # set to 1,2,3,4,5 or 6
  config.confirmations = 3

  # webhooks
  config.allowwebhooks = true
  config.webhook_domain = "domain.com" # No subdomains or IPs supported
  config.webhook_port = "3000"

  config.node_path = "m/0/"
  config.master_public_key = "your xpub master public key here"

  config.testnet = true
  config.adapter = 'blocktrail'
end
