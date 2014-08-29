Feature: Testing an empty widget

Scenario: An unsaved widget should respond to bitcoin_payments
Given an unsaved widget
Then the widget should have 0 bitcoin_payments