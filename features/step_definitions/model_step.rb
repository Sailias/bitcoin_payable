Given /^an unsaved widget$/ do
  @widget = Widget.new
end

Given /^a saved widget$/ do
  @widget = Widget.create
end

Given /^a new bitcoin_payment$/ do
  @bitcoin_payment = @widget.bitcoin_payments.new
end
