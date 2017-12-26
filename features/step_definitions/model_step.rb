Given /^an unsaved widget$/ do
  @widget = Widget.new
end

Given /^a saved widget$/ do
  @widget = Widget.create
end

Given /^a new coin_payment$/ do
  @coin_payment = @widget.coin_payments.new
end
