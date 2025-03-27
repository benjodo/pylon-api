#!/usr/bin/env ruby
require 'bundler/setup'
require 'pylon'

client = Pylon::Client.new(api_key: ENV['PYLON_API_KEY'])

# Test the API
begin
  me = client.get_current_user
  puts "Successfully connected as: #{me['email']}"
rescue => e
  puts "Error: #{e.message}"
end 