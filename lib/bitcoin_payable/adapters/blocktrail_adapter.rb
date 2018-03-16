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
        blockTime: DateTime.parse(tx_data["block_time"]).to_time.to_i if tx_data["block_time"],
        confirmations: tx_data["confirmations"],
        estimatedTxTime: DateTime.parse(tx_data["first_seen_at"]).to_time.to_i if tx_data["first_seen_at"],
        estimatedTxValue: tx_data["estimated_value"]
      }
    end

    # Create a Blocktrail subscription for this address
    def subscribe_to_address_push_notifications(payment)
      # Update the webhook to tell Blocktrail where to post to when a transaction is received
      @client.setup_webhook(
        webhook_url(payment), 
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

    private

    def webhook_url(payment)
      Rails.application.routes.url_for(
        user: ENV['BITCOIN_PAYABLE_WEBHOOK_USER'],
        password: ENV['BITCOIN_PAYABLE_WEBHOOK_PASS'],
        controller: "bitcoin_payable/bitcoin_payment_transaction",
        action: "notify_transaction",
        bitcoin_payment_id: payment.id,
        host: BitcoinPayable.config.webhook_domain
      )
    end

  end
end
