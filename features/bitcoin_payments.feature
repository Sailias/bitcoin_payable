Feature: BitcoinPayment creation, validation and state

Background:
  Given a saved widget
  And a new bitcoin_payment
  Then the bitcoin_payment field price is set to 10000
    And the bitcoin_payment field reason is set to New
  When the bitcoin_payment is saved

Scenario: A saved widget can create a payment
Then the bitcoin_payment should have an address
  And the bitcoin_payment should have the state pending

Scenario: When the payment processor is run the payment status should be pending
When the payment_processor is run
Then the bitcoin_payment should have the state pending

Scenario: When a payment is made for 1/2 the amount, the status should be partial payment
When the btc_amount_due is set
  And a payment is made for 50 percent
When the payment_processor is run
Then the bitcoin_payment should have the state partial_payment
  And the amount paid percentage should be 50%

Scenario: When a payment is made for 1/2 the amount, the status should be partial payment
When the btc_amount_due is set
  And a payment is made for 100 percent
When the payment_processor is run
Then the bitcoin_payment should have the state paid_in_full
  And the amount paid percentage should be 100%

Scenario: When the price bombs the payment is still honoured at the conversion rate
When the btc_amount_due is set
  And the currency_conversion is 1
  And a payment is made for 50 percent
When the payment_processor is run
Then the bitcoin_payment should have the state partial_payment
  And the amount paid percentage should be 50%

Scenario: When a partial payment is made and another payment made it should complete
Scenario: When a payment is made for 1/2 the amount, the status should be partial payment
When the btc_amount_due is set
  And a payment is made for 50 percent
When the payment_processor is run
Then the bitcoin_payment should have the state partial_payment
  And the amount paid percentage should be 50%
Then a payment is made for 50 percent
When the payment_processor is run
Then the bitcoin_payment should have the state paid_in_full
  And the amount paid percentage should be 100%