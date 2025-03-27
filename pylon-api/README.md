# Pylon API Ruby Client

A Ruby client for the [Pylon API](https://docs.usepylon.com/pylon-docs/developer/api/api-reference).

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
user, response = client.get_current_user
```

#### Accounts

```ruby
# List accounts with pagination
accounts, response = client.list_accounts(page: 1, per_page: 20)

# Get a specific account
account, response = client.get_account('account_id')
```

#### Issues

```ruby
# List issues (requires time range, max 30 days)
start_time = Time.now.utc - 86400 # 24 hours ago
end_time = Time.now.utc

issues, response = client.list_issues(
  start_time: start_time.strftime("%Y-%m-%dT%H:%M:%SZ"),
  end_time: end_time.strftime("%Y-%m-%dT%H:%M:%SZ"),
  page: 1,
  per_page: 20,
  status: 'open' # optional filter
)

# Create an issue
issue, response = client.create_issue(
  title: 'New Issue',
  description: 'Issue description'
)
```

#### Teams

```ruby
# List teams
teams, response = client.list_teams(page: 1, per_page: 20)

# Create a team
team, response = client.create_team(name: 'Engineering')

# Get a specific team
team, response = client.get_team('team_id')
```

#### Users

```ruby
# List users
users, response = client.list_users(page: 1, per_page: 20)

# Create a user
user, response = client.create_user(
  email: 'user@example.com',
  name: 'John Doe'
)
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

For more information about the project, including contributing guidelines and development setup, see the [main project README](../README.md).

## Contributing

Bug reports and pull requests are welcome on GitHub. Please see the [main project README](../README.md) for more details. 