require 'blocktrail'

module BitcoinPayable::Adapters
  class BlocktrailAdapter < Base
    
    def initialize
      @client ||= Blocktrail::Client.new(testnet: BitcoinPayable.config.testnet)
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

    # Create a Blocktrail subscription for this address
    def subscribe_to_address_push_notifications(payment)
      # Update the webhook to tell Blocktrail where to post to when a transaction is received
      @client.setup_webhook(
        webhook_url, 
        payment.id
      )

      # Subscribe to the address to the webhook
      @client.subscribe_address_transactions(
        payment.id, 
        payment.address, 
        BitcoinPayable.config.confirmations
      )
    end

    # Unsubscribe from the Blocktrail subscription for this address
    def unsubscribe_to_address_push_notifications(payment)
      begin
        @client.unsubscribe_address_transactions(payment.id, payment.address)
      rescue Blocktrail::Exceptions::ObjectNotFound => e
        puts "Blocktrail subscription for address #{address} not found: #{e}"
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

    private

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

  end
end
