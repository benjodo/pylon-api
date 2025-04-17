# frozen_string_literal: true

require "pylon"

# Initialize client with API key from environment variable
client = Pylon::Client.new(api_key: ENV["PYLON_API_KEY"], debug: true)

# Get current user details
me = client.get_current_user
puts "\n=== Current User ==="
puts "ID: #{me.id}"
puts "Name: #{me.name}"
puts "Email: #{me.email}"
puts "Role: #{me.role}"

# List issues from the last 7 days
puts "\n=== Recent Issues ==="
start_time = (Time.now.utc - (7 * 86400)).iso8601
end_time = Time.now.utc.iso8601

issues = client.list_issues(
  start_time: start_time,
  end_time: end_time,
  page: 1,
  per_page: 5
)

puts "Found #{issues.size} issues"
issues.each do |issue|
  puts "#{issue.id}: #{issue.title} (Status: #{issue.status})"
  if issue.tags && !issue.tags.empty?
    puts "  Tags: #{issue.tags.map { |t| t['name'] }.join(', ')}"
  end
end

# Create and retrieve an issue
puts "\n=== Create Issue ==="
new_issue = client.create_issue(
  title: "Test issue from Ruby client",
  description: "This is a test issue created by the Ruby client object model example"
)
puts "Created issue #{new_issue.id}: #{new_issue.title}"
puts "Description: #{new_issue.description}"
puts "Status: #{new_issue.status}"
puts "Created at: #{new_issue.created_at}"

# Retrieve the issue we just created
puts "\n=== Retrieve Issue ==="
issue = client.get_issue(new_issue.id)
puts "Retrieved issue #{issue.id}: #{issue.title}"
puts "Description: #{issue.description}"
puts "Status: #{issue.status}"
puts "Created at: #{issue.created_at}"

# Demonstrate getting the raw response
puts "\n=== Raw Response Access ==="
response = issue._response
puts "Response status: #{response.status}"
puts "Response headers: #{response.headers['content-type']}"

puts "\nExample completed successfully!"