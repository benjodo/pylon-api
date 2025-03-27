#!/usr/bin/env ruby
require 'pylon'

# Initialize the client with your API key and enable debug mode
client = Pylon::Client.new(api_key: ENV['PYLON_API_KEY'], debug: false)  # Temporarily enable debug to see response structure

def display_rate_limit_info(raw_response)
  return unless raw_response && raw_response.respond_to?(:headers)
  
  remaining = raw_response.headers['x-rate-limit-remaining']
  limit = raw_response.headers['x-rate-limit-limit']
  reset_time = raw_response.headers['x-rate-limit-reset']
  
  if remaining || limit || reset_time
    puts "\nRate limit info:"
    puts "  Remaining requests: #{remaining || 'N/A'}"
    puts "  Total limit: #{limit || 'N/A'}"
    if reset_time
      begin
        reset_time_obj = Time.at(reset_time.to_i)
        puts "  Reset time: #{reset_time_obj.utc}"
      rescue => e
        puts "  Reset time: #{reset_time} (raw value)"
      end
    end
  else
    puts "\nNo rate limit information available in response"
    if ENV['PYLON_DEBUG']
      puts "Debug: Response headers:"
      raw_response.headers.each do |key, value|
        puts "  #{key}: #{value}"
      end
    end
  end
end

# Enable debug mode for troubleshooting
ENV['PYLON_DEBUG'] = 'false'

begin
  # Test the connection by getting current user info
  me, raw_response = client.get_current_user
  if me
    puts "\nCurrent user info:"
    puts "  Email: #{me['email']}" if me['email']
    puts "  Name: #{me['name']}" if me['name']
    puts "  ID: #{me['id']}" if me['id']
    puts "  Role: #{me['role']}" if me['role']
  else
    puts "Could not fetch user info"
  end
  display_rate_limit_info(raw_response)
  
  
  if ENV['PYLON_DEBUG']
    puts "\nDebug: Raw response headers:"
    raw_response.headers.each do |key, value|
      puts "  #{key}: #{value}"
    end
  end
  
  # List issues from the last 24 hours
  puts "\nListing issues from the last 24 hours:"
  start_time = (Time.now.utc - 86400).iso8601  # 24 hours ago
  end_time = Time.now.utc.iso8601
  
  issues, raw_response = client.list_issues(
    start_time: start_time,
    end_time: end_time,
    status: 'open'  # optional filter
  )
  
  if issues.empty?
    puts "No open issues found"
  else
    issues.each do |issue|
      puts "- #{issue['title']} (#{issue['id']})"
      puts "  Status: #{issue['state']}"
      puts "  Created: #{issue['created_at']}"
    end
  end
  display_rate_limit_info(raw_response)
  
  puts "\nListing teams:"
  teams, raw_response = client.list_teams
  if teams.empty?
    puts "No teams found"
  else
    teams.each do |team|
      puts "- #{team['name']} (#{team['id']})"
    end
  end
  display_rate_limit_info(raw_response)

  puts "\nListing tags:"
  tags, raw_response = client.list_tags
  if tags.nil? || tags.empty?
    puts "No tags found"
  else
    
    # Handle both array and hash responses
    tag_list = tags.is_a?(Hash) ? tags['tags'] : tags
    tag_list ||= []
    
    tag_list.each do |tag|
      name = tag['value']
      color = tag['hex_color']
      id = tag['id']
      object_type = tag['object_type']
      puts "- #{name} (#{color}) [#{object_type}] [#{id}]"
    end
  end
  display_rate_limit_info(raw_response)

  puts "\nListing ticket forms:"
  begin
    forms, raw_response = client.list_ticket_forms
    if forms.nil? || forms.empty?
      puts "No ticket forms found"
    else
      
      forms.each do |form|
        puts "- #{form['name'] || form['title']} (#{form['id']})"
        if form['fields']
          puts "  Fields:"
          form['fields'].each do |field|
            puts "    - #{field['name']} (#{field['type']})"
          end
        end
      end
    end
    display_rate_limit_info(raw_response)
  rescue Pylon::ResourceNotFoundError => e
    puts "Note: Ticket forms feature might not be available in your plan"
  end

rescue Pylon::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Pylon::ValidationError => e
  puts "Validation error: #{e.message}"
rescue Pylon::ResourceNotFoundError => e
  puts "Resource not found: #{e.message}"
rescue Pylon::ApiError => e
  if e.response && e.response.status == 429
    puts "Rate limit exceeded: #{e.message}"
    reset_time = e.response.headers['x-rate-limit-reset']
    puts "Please wait until #{Time.at(reset_time.to_i).utc} before making more requests" if reset_time
  else
    puts "API error: #{e.message}"
    if e.response && e.response.body
      puts "Response body: #{e.response.body.inspect}"
    end
  end
end 