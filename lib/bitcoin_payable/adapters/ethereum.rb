require 'eth'

module BitcoinPayable
  module Adapters
    class Ethereum < Coin
      WEI_IN_ETHER = 1_000_000_000_000_000_000

      def self.convert_subunit_to_main(wei)
        wei / WEI_IN_ETHER.to_f
      end

      def self.convert_main_to_subunit(ether)
        (ether * WEI_IN_ETHER).to_i
      end

      # @param price: cents in fiat currency
      # @param exchange_rate: fiat cents per ether
      # @returns price in wei
      def self.exchange_price(price, exchange_rate)
        (price / exchange_rate.to_f * WEI_IN_ETHER).ceil
      end

      def self.get_rate
        super('ETH')
      end

      def self.get_transactions_for(address)
        url = "#{adapter_domain}/api?module=account&action=txlist&address=#{address}&tag=latest"
        url += '?apiKey=' + BitcoinPayable.configuration.eth.adapter_api_key if BitcoinPayable.configuration.eth.adapter_api_key

        response = get_request(url)
        json = JSON.parse(response.body)
        json['result'].map {|tx| convert_transactions(tx, address)}
      end

      def self.create_address(id)
        mnemonic = BitcoinPayable.configuration.eth.mnemonic

        raise 'mnemonic is required' unless mnemonic

        master = MoneyTree::Master.new(seed_hex: ::Bitcoin::Trezor::Mnemonic.to_seed(mnemonic))
        node = master.node_for_path("m/44'/60'/0'/0/#{id}")
        key = Eth::Key.new(priv: node.private_key.to_hex)
        key.address
      end

      private_class_method def self.adapter_domain
        @adapter_domain ||= if BitcoinPayable.configuration.testnet
          'https://rinkeby.etherscan.io'
        else
          'https://api.etherscan.io'
        end
      end

      # Example response:
      # {
      #   status: "1",
      #   message: "OK",
      #   result: [
      #     {
      #       blockNumber: "4790248",
      #       timeStamp: "1514144760",
      #       hash: "0x52345400e42a15ba883fb0e314d050a7e7e376a30fc59dfcd7b841007d5d710c",
      #       nonce: "215964",
      #       blockHash: "0xe6ed0d98586cae04be57e515ca7773c020b441de60a467cd2773877a8996916f",
      #       transactionIndex: "4",
      #       from: "0xd24400ae8bfebb18ca49be86258a3c749cf46853",
      #       to: "0x911f9d574d1ca099cae5ab606aa9207fe238579f",
      #       value: "10000000000000000",
      #       gas: "90000",
      #       gasPrice: "28000000000",
      #       isError: "0",
      #       txreceipt_status: "1",
      #       input: "0x",
      #       contractAddress: "",
      #       cumulativeGasUsed: "156270",
      #       gasUsed: "21000",
      #       confirmations: "154"
      #     }
      #   ]
      # }
      private_class_method def self.convert_transactions(transaction, address)
        {
          txHash: transaction['hash'],
          blockHash: transaction['blockHash'],
          blockTime: nil, # Not supported
          estimatedTxTime: transaction['timeStamp'],
          estimatedTxValue: transaction['value'], # Units here are "Wei", comparable to "Satoshi"
          confirmations: transaction['confirmations']
        }
      end
    end
  end
end
