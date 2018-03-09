module BitcoinPayable::Adapters
  class Base

    class << self
      def fetch_adapter
        unless BitcoinPayable.config.adapter.blank?
          api = BitcoinPayable.config.adapter
          adapter_class = api.camelize + 'Adapter'
          adapter_class = BitcoinPayable::Adapters.const_get(adapter_class)
          adapter = adapter_class.new
        else
          raise "Please specify an adapter"
        end
      end
    end

  end
end
