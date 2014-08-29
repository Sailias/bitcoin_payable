Given /^there should be (\d+) currency_conversions?$/ do |n|
  @currency_conversions.should_not be_nil
  @currency_conversions.count.should eql(n.to_i)
end