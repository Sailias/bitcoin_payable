Given /^the bitcoin_payment field (\S*) is set to (.*)/ do |field, value|
  @bitcoin_payment.send("#{field}=", value)
end

Given /^the bitcoin_payment is saved$/ do
  @bitcoin_payment.save
  @bitcoin_payment.reload.new_record?.should be_false
end

Given /^the bitcoin_payment should have an address$/ do
  @bitcoin_payment.address.should_not be_nil
end

Given /^the bitcoin_payment should have the state (\S+)$/ do |state|
  @bitcoin_payment.state.should eq(state)
end