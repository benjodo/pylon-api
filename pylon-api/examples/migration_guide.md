# Pylon API Client Migration Guide

## Object Model Introduction

Version 1.1.0 of the Pylon API Ruby client introduces a new object model that provides a more Ruby-like interface for working with the Pylon API. This guide explains how to migrate from the previous hash-based response model to the new object model.

## Key Changes

1. API methods now return Ruby objects instead of hash/response pairs
2. Access attributes via methods (e.g., `issue.title` instead of `issue["title"]`)
3. Collections are enumerable and can be iterated directly (e.g., `issues.each`)
4. The original response is still accessible via the `_response` attribute

## Migration Examples

### Before (v0.2.x)

```ruby
# Getting a user
user, response = client.get_current_user
puts "User ID: #{user['id']}"
puts "User Name: #{user['name']}"
puts "Response Status: #{response.status}"

# Listing issues
issues, response = client.list_issues(start_time: start_time, end_time: end_time)
issues.each do |issue|
  puts "#{issue['id']}: #{issue['title']}"
end

# Creating an issue
issue, response = client.create_issue(title: "New Issue", description: "Test")
issue_id = issue["id"]
```

### After (v1.1.0+)

```ruby
# Getting a user
user = client.get_current_user
puts "User ID: #{user.id}"
puts "User Name: #{user.name}"
puts "Response Status: #{user._response.status}"

# Listing issues
issues = client.list_issues(start_time: start_time, end_time: end_time)
issues.each do |issue|
  puts "#{issue.id}: #{issue.title}"
end

# Creating an issue
issue = client.create_issue(title: "New Issue", description: "Test")
issue_id = issue.id
```

## Accessing the Underlying Response

If you need access to the HTTP response (for headers, status code, etc.):

```ruby
user = client.get_current_user
response = user._response

# Get rate limit information from headers
remaining = response.headers["x-rate-limit-remaining"]
limit = response.headers["x-rate-limit-limit"]
reset = response.headers["x-rate-limit-reset"]

puts "API Rate Limit: #{remaining}/#{limit} (resets at #{Time.at(reset.to_i)})"
```

## Converting to Hash

You can convert any model object back to a hash:

```ruby
user = client.get_current_user
user_hash = user.to_h  # or user.to_hash
```

## Validating Against the API

We've included an API validation script that can be used to ensure our client models match the actual API responses:

```bash
PYLON_API_KEY=your_api_key ruby examples/api_validation.rb
```

This script will generate a report showing which models and fields are available and whether they match our implementation.

## Compatibility Notes

The object model is fully backward compatible with existing code that uses the previous hash-based response model. To maintain this compatibility:

1. Model objects respond to `[]` for hash-like access: `user["name"]` still works
2. Model objects can be converted to hashes with `to_h` or `to_hash`
3. Methods that previously returned `[data, response]` now return model objects with a `_response` attribute