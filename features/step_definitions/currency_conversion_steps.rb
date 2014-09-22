Given /^there should be (\d+) currency_conversions?$/ do |n|
  expect(@currency_conversions).to_not be_nil
  expect(@currency_conversions.count).to eq(n.to_i)
end

Given /^the currency_conversion is (\d+)$/ do |conversion_rate|
  BitcoinPayable::CurrencyConversion.create!(
    currency: 1,
    btc: conversion_rate.to_i,
  )
  @currency_conversions = BitcoinPayable::CurrencyConversion.all
end