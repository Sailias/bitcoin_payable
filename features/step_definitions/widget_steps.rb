Given /^the widget should have (\d+) bitcoin_payments$/ do |n|
  expect(@widget.bitcoin_payments.count).to eq(n.to_i)
end