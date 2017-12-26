Given /^the widget should have (\d+) coin_payments$/ do |n|
  expect(@widget.coin_payments.count).to eq(n.to_i)
end
