class Widget < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :bitcoin_payments, class_name: "BitcoinPayable::BitcoinPayment", foreign_key: 'payable_id'
end
