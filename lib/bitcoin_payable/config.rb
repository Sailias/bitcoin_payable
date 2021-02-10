require 'singleton'

module BitcoinPayable
  class Config
    include Singleton
    attr_accessor(
      # Core
      :master_public_key,
      :node_path,
      :currency,
      :adapter,
      :adapter_api_key,
      :testnet,
      :confirmations,
      :payment_variance,
      :processing_days,
      :adapter_url,
      :request_delay,

      # Pricing
      :bitcoinaverage_key,
      :open_exchange_key,
      :rate_calculation,

      # Webhooks
      :allowwebhooks,
      :webhook_subdomain,
      :webhook_domain,
      :webhook_port
    )

    def initialize
      @currency ||= :cad
      @confirmations ||= 6
      @rate_calculation ||= :daily_average
      @request_delay ||= 0.5

      # Allow a number of cents difference between price and payment amount
      # to account for payments very close to the price.
      # Even though we honour the price for 30 minutes,
      # there will still be payments made close to the time limit that are very close to the amount due.
      @payment_variance ||= 0

      # Only process payments once for the last X number of days
      @processing_days ||= 30
    end

    def network
      @testnet == false ? :bitcoin : :bitcoin_testnet
    end
  end
end
