module BitcoinPayable::Adapters
  class Base

    def self.fetch_adapter
      if BitcoinPayable.config.adapter.blank?
        raise "Please specify an adapter"
      else
        api = BitcoinPayable.config.adapter
        adapter_class = api.camelize + 'Adapter'
        adapter_class = BitcoinPayable::Adapters.const_get(adapter_class)
        adapter = adapter_class.new
      end
    end

  end
end
