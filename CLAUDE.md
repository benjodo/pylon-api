# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Install dependencies: `bundle install`
- Run all tests: `rake spec`
- Run single test: `bundle exec rspec spec/pylon/client_spec.rb:LINE_NUMBER`
- Check code style: `bundle exec rubocop`
- Build gem: `gem build pylon-api.gemspec`
- Install locally: `bundle exec rake install`

## Testing Commands
- Run integration test: `ruby test/test.rb` (set `PYLON_API_KEY` env var)
- Check test coverage: `bundle exec rspec` (see coverage/index.html)

## Code Style Guidelines
- Follow Ruby style guidelines (frozen_string_literal, 2-space indent)
- Use snake_case for methods and variables
- Include YARD-style documentation for public methods
- Add appropriate error handling using custom error classes
- Wrap external API calls in appropriate error handling
- Keep code DRY and follow Ruby idioms
- Follow existing patterns for API methods (naming, parameter handling)
- Ensure all new code has accompanying tests