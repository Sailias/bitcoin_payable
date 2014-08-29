Given /^the widget should have (\d+) bitcoin_payments$/ do |n|
  @widget.bitcoin_payments.count.should eql(n.to_i)
end