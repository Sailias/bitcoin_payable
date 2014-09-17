Given /^the bitcoin_payment field (\S*) is set to (.*)/ do |field, value|
  @bitcoin_payment.send("#{field}=", value)
end

Given /^the bitcoin_payment is saved$/ do
  @bitcoin_payment.save
  expect(@bitcoin_payment.reload.new_record?).to be(false)
end

Given /^the bitcoin_payment should have an address$/ do
  expect(@bitcoin_payment.address).to_not be(nil)
end

Given /^the bitcoin_payment should have the state (\S+)$/ do |state|
  expect(@bitcoin_payment.reload.state).to eq(state)
end

Given /^the btc_amount_due is set$/ do
  @btc_amount_due = @bitcoin_payment.calculate_btc_amount_due
end

Given /^a payment is made for (\d+) percent$/ do |percentage|
  @bitcoin_payment.transactions.create!(estimated_value: BitcoinPayable::BitcoinCalculator.convert_bitcoins_to_satoshis(@btc_amount_due * (percentage.to_f / 100.0)), btc_conversion: @bitcoin_payment.btc_conversion)
end

Given(/^the amount paid percentage should be greater than (\d+)%$/) do |percentage|
  expect(@bitcoin_payment.currency_amount_paid / @bitcoin_payment.price.to_f).to be >= (percentage.to_f / 100)
end

Given(/^the amount paid percentage should be less than (\d+)%$/) do |percentage|
  expect(@bitcoin_payment.currency_amount_paid / @bitcoin_payment.price).to be < (percentage.to_f / 100)
end

Given(/^the amount paid percentage should be (\d+)%$/) do |percentage|
  expect(@bitcoin_payment.currency_amount_paid / @bitcoin_payment.price.to_f).to  eq(percentage.to_f / 100)
end