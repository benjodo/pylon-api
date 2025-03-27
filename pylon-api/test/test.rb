#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "pylon"

client = Pylon::Client.new(api_key: ENV.fetch("PYLON_API_KEY", nil))

# Test the API
begin
  me = client.get_current_user
  puts "Successfully connected as: #{me['email']}"
rescue StandardError => e
  puts "Error: #{e.message}"
end
