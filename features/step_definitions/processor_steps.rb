When /^the payment_processor is run$/ do
  BitcoinPayable::PaymentProcessor.perform
end