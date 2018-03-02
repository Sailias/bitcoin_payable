module BitcoinPayable
  module Rails3support

    def rails3?(&block)
      if Rails.version.start_with? '3'
        block.call if block_given?
        return true
      else
        return false
      end
    end

  end

  module MonkeyRender
    extend Rails3support

    if rails3?
      class ActionController::Base
        def render(options = nil, extra_options = {}, &block)
          options[:text] = options.delete(:plain) unless options.nil?
          super(options, extra_options, &block)
        end
      end
    end

  end
end
