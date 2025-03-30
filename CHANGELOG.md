# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2024-03-21

### Added
- Added `snooze_issue` method to support the new issue snooze endpoint

## [0.1.0] - 2024-03-21

### Added
- Initial release of the Pylon API Ruby client
- Comprehensive client implementation with support for all major API endpoints:
  - Accounts management
  - Attachments handling
  - Contacts management
  - Custom fields
  - Issues tracking
  - Knowledge base articles
  - Tags management
  - Teams management
  - Ticket forms
  - User roles
  - Users management
- Robust error handling with specific error classes:
  - `Pylon::AuthenticationError`
  - `Pylon::ResourceNotFoundError`
  - `Pylon::ValidationError`
  - `Pylon::ApiError`
- Pagination support for list endpoints
- Debug mode for request/response logging
- Comprehensive test suite with RSpec
- YARD documentation for all methods
- MIT License

[0.2.0]: https://github.com/benjodo/pylon-api/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/benjodo/pylon-api/releases/tag/v0.1.0 