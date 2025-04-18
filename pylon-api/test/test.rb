#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "pylon"
require "tempfile"

if ENV["PYLON_API_KEY"].nil?
  puts "Error: Please set the PYLON_API_KEY environment variable"
  exit 1
end

client = Pylon::Client.new(api_key: ENV["PYLON_API_KEY"], debug: true)

puts "--------- Testing Pylon API Attachment Upload Methods -----------"

# Test 1: Get current user (to verify API key is working)
begin
  me = client.get_current_user
  puts "Successfully connected as: #{me.name}"
rescue => e
  puts "Error connecting to API: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end

# Test 2: Create attachment from string content
begin
  puts "\nTest 2: Creating attachment from string content..."
  string_content = "This is a test file created from string content."
  attachment = client.create_attachment(string_content, description: "Test string attachment")
  puts "Success! Attachment created with ID: #{attachment.id}"
  puts "URL: #{attachment.url}"
  puts "Name: #{attachment.name}" if attachment.respond_to?(:name)
  puts "Description: #{attachment.description}" if attachment.respond_to?(:description)
rescue => e
  puts "Error creating string attachment: #{e.message}"
  puts e.backtrace.join("\n")
end

# Test 3: Create attachment from file
begin
  puts "\nTest 3: Creating attachment from file..."
  temp_file = Tempfile.new(["test_file", ".txt"])
  temp_file.write("This is content from a file object.")
  temp_file.rewind

  attachment = client.create_attachment(temp_file, description: "Test file attachment")
  puts "Success! Attachment created with ID: #{attachment.id}"
  puts "URL: #{attachment.url}"
  puts "Name: #{attachment.name}" if attachment.respond_to?(:name)
  puts "Description: #{attachment.description}" if attachment.respond_to?(:description)

  temp_file.close
  temp_file.unlink
rescue => e
  puts "Error creating file attachment: #{e.message}"
  puts e.backtrace.join("\n")
end

# Test 4: Create attachment from URL
begin
  puts "\nTest 4: Creating attachment from URL..."
  attachment = client.create_attachment(nil,
    file_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Ruby_logo.svg/200px-Ruby_logo.svg.png",
    description: "Ruby logo from URL"
  )
  puts "Success! Attachment created with ID: #{attachment.id}"
  puts "URL: #{attachment.url}"
  puts "Name: #{attachment.name}" if attachment.respond_to?(:name)
  puts "Description: #{attachment.description}" if attachment.respond_to?(:description)
rescue => e
  puts "Error creating URL attachment: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "\nFinished testing!"
