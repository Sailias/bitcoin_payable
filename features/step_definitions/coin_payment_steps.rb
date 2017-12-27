Given /^the coin_payment field (\S*) is set to (.*)/ do |field, value|
  @coin_payment.send("#{field}=", value)
end

Given /^the coin_payment is saved$/ do
  @coin_payment.save
  expect(@coin_payment.reload.new_record?).to be(false)
end

Given /^the coin_payment should have an address$/ do
  expect(@coin_payment.address).to_not be(nil)
end

Given /^the coin_payment should have the state (\S+)$/ do |state|
  expect(@coin_payment.reload.state).to eq(state)
end

Given /^the coin_amount_due is set$/ do
  @coin_amount_due = @coin_payment.calculate_coin_amount_due
end

Given /^a payment is made for (\d+) percent$/ do |percentage|
  BitcoinPayable::Adapters::Bitcoin
    .stub(:get_transactions_for)
    .with(@coin_payment.address)
    .and_return([{
      txHash: SecureRandom.uuid,
      blockHash: '00000000000000606aa74093ed91d657192a3772732ee4d99a7b7be8075eafa2',
      blockTime: DateTime.iso8601('2017-12-26T21:38:44.000+00:00'),
      estimatedTxTime: DateTime.iso8601('2017-12-26T21:30:19.858+00:00'),
      estimatedTxValue: @coin_amount_due * (percentage.to_f / 100.0),
      confirmations: 1
    }])
end

Given(/^the amount paid percentage should be greater than (\d+)%$/) do |percentage|
  expect(@coin_payment.currency_amount_paid / @coin_payment.price.to_f).to be >= (percentage.to_f / 100)
end

Given(/^the amount paid percentage should be less than (\d+)%$/) do |percentage|
  expect(@coin_payment.currency_amount_paid / @coin_payment.price).to be < (percentage.to_f / 100)
end

Given(/^the amount paid percentage should be (\d+)%$/) do |percentage|
  expect(@coin_payment.currency_amount_paid / @coin_payment.price.to_f).to eq(percentage.to_f / 100)
end
