# Pylon API Ruby Client

A Ruby client for the [Pylon API](https://docs.usepylon.com/pylon-docs/developer/api/api-reference).

[![Gem Version](https://badge.fury.io/rb/pylon-api.svg)](https://badge.fury.io/rb/pylon-api)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pylon-api'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install pylon-api
```

## Usage

First, initialize a client with your API key:

```ruby
require 'pylon'

client = Pylon::Client.new(api_key: 'your_api_key')

# Enable debug mode to see request/response details
client = Pylon::Client.new(api_key: 'your_api_key', debug: true)
```

### Examples

#### Current User

```ruby
# Get current user details
me = client.get_current_user
```

#### Accounts

```ruby
# List accounts with pagination
accounts = client.list_accounts(page: 1, per_page: 20)

# Get a specific account
account = client.get_account('account_id')
```

#### Issues

```ruby
# List issues (requires time range, max 30 days)
start_time = Time.now.utc - 86400 # 24 hours ago
end_time = Time.now.utc

issues = client.list_issues(
  start_time: start_time.iso8601,
  end_time: end_time.iso8601,
  page: 1,
  per_page: 20,
  status: 'open' # optional filter
)

# Create an issue
issue = client.create_issue(
  title: 'New Issue',
  description: 'Issue description'
)
```

#### Teams

```ruby
# List teams
teams = client.list_teams(page: 1, per_page: 20)

# Create a team
team = client.create_team(name: 'Engineering')

# Get a specific team
team = client.get_team('team_id')
```

#### Users

```ruby
# List users
users = client.list_users(page: 1, per_page: 20)

# Create a user
user = client.create_user(
  email: 'user@example.com',
  name: 'New User'
)

# Get a specific user
user = client.get_user('user_id')

# Update a user
updated_user = client.update_user('user_id', { name: 'Updated Name' })
```

#### Tags

```ruby
# List tags
tags = client.list_tags(page: 1, per_page: 20)

# Create a tag
tag = client.create_tag(
  name: 'bug',
  color: '#ff0000'
)
```

#### Ticket Forms

```ruby
# List ticket forms
forms = client.list_ticket_forms(page: 1, per_page: 20)

# Create a ticket form
form = client.create_ticket_form(
  name: 'Bug Report',
  fields: [
    { name: 'severity', type: 'select' }
  ]
)
```

#### Attachments

```ruby
# Create an attachment
attachment = client.create_attachment(file_content)
```

## Error Handling

The client will raise different types of errors based on the API response:

- `Pylon::AuthenticationError` - When the API key is invalid
- `Pylon::ResourceNotFoundError` - When the requested resource is not found
- `Pylon::ValidationError` - When the request parameters are invalid
- `Pylon::ApiError` - For other API errors

Example:

```ruby
begin
  client.get_issue('non_existent_id')
rescue Pylon::ResourceNotFoundError => e
  puts "Issue not found: #{e.message}"
rescue Pylon::ApiError => e
  puts "API error: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Testing Locally

To test the gem locally:

1. Build and install the gem:
```bash
gem build pylon-api.gemspec
gem install ./pylon-api-*.gem
```

2. Create a test script:
```ruby
require 'pylon'

client = Pylon::Client.new(api_key: ENV['PYLON_API_KEY'], debug: true)

begin
  me = client.get_current_user
  puts "Successfully connected as: #{me['email']}"
rescue => e
  puts "Error: #{e.message}"
end
```

3. Run with your API key:
```bash
PYLON_API_KEY=your_api_key_here ruby test.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the MIT License.
