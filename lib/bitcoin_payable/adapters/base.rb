module BitcoinPayable::Adapters
  class Base
    def self.load_adapters
      lib_dir = File.dirname(__FILE__)
      full_pattern = File.join(lib_dir, '*_adapter.rb')
      Dir.glob(full_pattern).each {|file| require file}
    end

    def self.fetch_adapter
      unless BitcoinPayable.config.adapter.blank?
        load_adapters
        api = BitcoinPayable.config.adapter
        adapter_class = api.capitalize + 'Adapter'
        adapter_class = BitcoinPayable::Adapters.const_get(adapter_class)
        adapter = adapter_class.new
      else
        raise "Please specify an adapter"
      end
    end

  end
end
