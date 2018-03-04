require 'blocktrail'

module BitcoinPayable::Adapters
  class BlocktrailAdapter
    @@each_block_subscribed = false

    def initialize
      coin = BitcoinPayable.config.crypto == :bch ? 'bcc' : BitcoinPayable.config.crypto.to_s

      if BitcoinPayable.config.testnet
        @client ||= Blocktrail::Client.new(coin: coin, testnet: true)
      else
        @client ||= Blocktrail::Client.new(coin: coin)
      end

      if BitcoinPayable.config.allowwebhooks
        @new_tx_webhook_id = Rails.application.class.parent_name
        @new_tx_webhook_url = webhook_url_for(:notify_transaction)
        setup_webhook(@new_tx_webhook_id, @new_tx_webhook_url)

        @new_block_webhook_id = Rails.application.class.parent_name + "-new-block"
        @new_block_webhook_url = webhook_url_for(:last_block)
        setup_webhook(@new_block_webhook_id, @new_block_webhook_url)

        # TODO: This should actually be triggered when Rails starts
        subscribe_notification_each_block
      end

    end

    def fetch_transactions_for_address(address)
      begin
        hash = @client.address_transactions(address)
        return if hash['data'].nil?
        hash['data'].map{|tx| convert_transactions(tx, address)}
      rescue Blocktrail::Exceptions::ObjectNotFound => e
        puts "Address #{address} not found:#{e}"
        return nil
      end
    end

    def convert_transactions(transaction, address)
      {
        confirmations:      transaction['confirmations'],
        transaction_hash:   transaction['hash'],
        block_hash:         transaction['block_hash'],
        block_number:       transaction['block_height'],
        block_time:         (Time.at(transaction['block_time']) if transaction['block_time']),  # Not supported
        estimated_time:     (Time.at(transaction[:estimated_time]) if transaction[:estimated_time]),
        estimated_value:    transaction['outputs'].sum do |outs|
                              outs['address'] == address ? outs['value'] : 0
                            end
      }
    end

    def get_last_block
      @client.block_latest['height']
    end

    def subscribe_tx_notifications(address)
      @client.subscribe_address_transactions(@new_tx_webhook_id, address, 0)
    end

    def desubscribe_tx_notifications(address)
      begin
        @client.unsubscribe_address_transactions(@new_tx_webhook_id,address)
      rescue Blocktrail::Exceptions::ObjectNotFound => e
        puts "Address #{address} not found:#{e}"
      end
    end

    def subscribe_notification_each_block
      return if @@each_block_subscribed
      begin
        @client.subscribe_new_blocks(@new_block_webhook_id)
        @@each_block_subscribed = true
      rescue Blocktrail::Exceptions::ObjectNotFound => e
        puts "Error when subscribint to notification for each block: #{e}"
        @@each_block_subscribed = false
      rescue Blocktrail::Exceptions::EndpointSpecificError => e
        puts "Notification for each block seems already subscribed: #{e}"
        @@each_block_subscribed = true
      end
    end

    private
    def setup_webhook(webhook_id, url)
      if @client.all_webhooks['data'].any?{|webhook| webhook["identifier"] == webhook_id}
        @client.update_webhook webhook_id, url
      else
        @client.setup_webhook url, webhook_id
      end
    end

    def webhook_url_for(action)
      Rails.application.routes.url_for(
                                :user => ENV['BITCOINPAYABLE_WEBHOOK_NAME'],
                                :password => ENV['BITCOINPAYABLE_WEBHOOK_PASS'],
                                :controller => "bitcoin_payable/bitcoin_payment_transaction",
                                :action => "#{action.to_s}",
                                :host => BitcoinPayable.config.webhook_domain,
                                :port => BitcoinPayable.config.webhook_port)
    end
  end
end
