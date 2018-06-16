require 'blocktrail'

module BitcoinPayable::Adapters
  class BlocktrailAdapter < Base

    def initialize
      coin = :bcc if BitcoinPayable.config.crypto == :bch # Blocktrail uses BCC tciker

      if BitcoinPayable.config.testnet
        @client ||= Blocktrail::Client.new(testnet: true, coin: coin.to_s)
      else
        @client ||= Blocktrail::Client.new(coin: coin.to_s)
      end
      super
    end

    def fetch_transactions_for_address(address)
      transactions = @client.address_transactions(address)
      transactions["data"].map do |tx|
        convert_transactions(
          {"data" => tx},
          address
        )
      end
    end

    def convert_transactions(transaction, address)
      tx_data = transaction["data"]

      {
        txHash: tx_data["hash"],
        blockHash: tx_data["block_hash"],
        blockTime: (tx_data["block_time"] ? DateTime.parse(tx_data["block_time"]).to_time.to_i : nil),
        confirmations: tx_data["confirmations"],
        estimatedTxTime: (tx_data["first_seen_at"] ? DateTime.parse(tx_data["first_seen_at"]).to_time.to_i : nil),
        estimatedTxValue: tx_data["estimated_value"]
      }
    end

    # Create a Blocktrail subscription for this address
    def subscribe_to_address_push_notifications(payment)
      # Update the webhook to tell Blocktrail where to post to when a transaction is received
      @client.setup_webhook(
        webhook_url(payment),
        payment.id.to_s
      )

      # Subscribe to the address to the webhook
      @client.subscribe_address_transactions(
        payment.id.to_s,
        payment.address,
        BitcoinPayable.config.confirmations
      )
    end

    # # Unsubscribe from the Blocktrail subscription for this address
    # def unsubscribe_to_address_push_notifications(payment)
    #   @client.unsubscribe_address_transactions(payment.id.to_s, payment.address)
    # rescue Blocktrail::Exceptions::ObjectNotFound => e
    #   puts "Blocktrail subscription for address #{address} not found: #{e}"
    # end

    def unsubscribe_to_address_push_notifications(payment)
        @client.delete_webhook(payment.id)
      rescue Blocktrail::Exceptions::EndpointSpecificError => e
        puts "Blocktrail webhook '#{payment.id}' not found: #{e}"
    end

    private

    def webhook_url(payment)
      Rails.application.routes.url_for(
        user: ENV['BITCOIN_PAYABLE_WEBHOOK_USER'],
        password: ENV['BITCOIN_PAYABLE_WEBHOOK_PASS'],
        controller: "bitcoin_payable/bitcoin_payment_transaction",
        action: "notify_transaction",
        bitcoin_payment_id: payment.id,
        host: BitcoinPayable.config.webhook_domain,
        protocol: BitcoinPayable.config.webhook_protocol.presence || 'http'
      )
    end

  end
end
