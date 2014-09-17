Given /^there should be (\d+) currency_conversions?$/ do |n|
  @currency_conversions.should_not be_nil
  @currency_conversions.count.should eql(n.to_i)
end

Given /^the currency_conversion is (\d+)$/ do |conversion_rate|
  BitcoinPayable::CurrencyConversion.create!(
    currency: 1,
    btc: conversion_rate.to_i,
  )
  @currency_conversions = BitcoinPayable::CurrencyConversion.all
end