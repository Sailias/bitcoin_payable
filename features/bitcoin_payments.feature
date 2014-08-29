Feature: BitcoinPayment creation, validation and state

Background:
  Given a saved widget

Scenario Outline: A saved widget can create a payment
Given a new bitcoin_payment
Then the bitcoin_payment field <field> is set to <value>
  And the bitcoin_payment field amount_due is set to 1
When the bitcoin_payment is saved
Then the bitcoin_payment should have an address
  And the bitcoin_payment should have the state pending

Examples:

| field     | value       |
| reason    | New Payment |



