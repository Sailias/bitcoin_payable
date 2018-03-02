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
        def render(options, &block)
          options[:text] = options.delete :plain
          super(options, block)
        end
      end
    end

  end
end
