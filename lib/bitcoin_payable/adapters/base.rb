module BitcoinPayable::Adapters
  class Base
    def initialize
      if BitcoinPayable.config.allowwebhooks
        configure_webhooks
        subscribe_notification_each_block
      end
    end

    def configure_webhooks
    end

    def subscribe_notification_each_block
    end

    def desubscribe_tx_notifications
      raise "Adapter #{self} doesn't support notifications on transactions"
    end

    def subscribe_tx_notifications
      raise "Adapter #{self} doesn't support notifications on transactions"
    end

    class << self
      def fetch_adapter
        unless BitcoinPayable.config.adapter.blank?
          load_adapters
          api = BitcoinPayable.config.adapter
          adapter_class = api.camelize + 'Adapter'
          adapter_class = BitcoinPayable::Adapters.const_get(adapter_class)
          adapter = adapter_class.new
        else
          raise "Please specify an adapter"
        end
      end
      def load_adapters
        lib_dir = File.dirname(__FILE__)
        full_pattern = File.join(lib_dir, '*_adapter.rb')
        Dir.glob(full_pattern).each {|file| require file}
      end
    end

  end
end
