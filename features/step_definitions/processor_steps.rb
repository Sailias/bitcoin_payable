When /^the payment_processor is run$/ do
  BitcoinPayable::PaymentProcessor.perform
end

When /^the pricing processor is run$/ do
  BitcoinPayable::PricingProcessor.perform
end
