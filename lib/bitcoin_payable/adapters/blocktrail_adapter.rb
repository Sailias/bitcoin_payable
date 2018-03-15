require 'blocktrail'

module BitcoinPayable::Adapters
  class BlocktrailAdapter < Base

    def initialize
      if BitcoinPayable.config.testnet
        @client ||= Blocktrail::Client.new(testnet: true)
      else
        @client ||= Blocktrail::Client.new
      end
      super
    end

    def fetch_transactions_for_address(address)
      transactions = @client.address_transactions(address)
      transactions["data"].map do |tx|
        convert_transactions(
          {"data": tx},
          address
        )
      end
    end

    def convert_transactions(transaction, address)
      tx_data = transaction["data"]

      {
        txHash: tx_data["hash"],
        blockHash: tx_data["block_hash"],
        blockTime: tx_data["block_time"],
        confirmations: tx_data["confirmations"],
        estimatedTxTime: DateTime.parse(tx_data["first_seen_at"]).to_time.to_i,
        estimatedTxValue: tx_data["estimated_value"]
      }
    end

    # Create a Blocktrail subscription for this address
    def subscribe_to_address_push_notifications(payment)
      # Update the webhook to tell Blocktrail where to post to when a transaction is received
      setup_webhook(payment)

      # Subscribe to the address to the webhook
      @client.subscribe_address_transactions(
        webhook_id(payment),
        payment.address,
        BitcoinPayable.config.confirmations
      )
    end

    # Unsubscribe from the Blocktrail subscription for this address
    def unsubscribe_to_address_push_notifications(payment)
      begin
        @client.delete_webhook webhook_id(payment)
      rescue Blocktrail::Exceptions::ObjectNotFound => e
        puts "Blocktrail subscription webhook #{webhook_id(payment)} not found: #{e}"
      end
    end

    private

    def setup_webhook(payment)
      begin
        @client.setup_webhook(
          webhook_url,
          webhook_id(payment),
        )
      rescue Blocktrail::Exceptions::EndpointSpecificError
        @client.update_webhook(
          webhook_id(payment),
          webhook_url
        )
      end
    end

    def webhook_url
      Rails.application.routes.url_for(
        :user => ENV['BITCOINPAYABLE_WEBHOOK_NAME'],
        :password => ENV['BITCOINPAYABLE_WEBHOOK_PASS'],
        :controller => "bitcoin_payable/bitcoin_payment_transaction",
        :action => "notify_transaction",
        :host => BitcoinPayable.config.webhook_domain,
        :subdomain => BitcoinPayable.config.webhook_subdomain,
        :port => BitcoinPayable.config.webhook_port
      )
    end

    def webhook_id(payment)
      "#{Rails.application.class.parent_name}-Payment-#{payment.id}"
    end
  end
end
