# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-09-20

### Added
- `list_email_suppressions` for `GET /email-suppressions` with optional `email`, `cursor`, and `limit` query parameters. Pass `email` to check a single address; an empty collection means it is not suppressed.
- `delete_email_suppression` for `DELETE /email-suppressions/{id}`
- `Pylon::Models::EmailSuppression` model (`id`, `email`, `reason`, `created_at`, `bounce_details`)

### Changed
- Documentation only: README examples now use `body_html` when creating issues and note the 365-day window for `list_issues`. No existing method signatures, paths, or return types changed.

## [1.1.1] - 2025-04-18

### Fixed
- Fixed URL-based file attachments by ensuring they use proper multipart form encoding

## [1.1.0] - 2024-04-16

### Added
- Ruby object model for all API resources
- Model objects that provide direct attribute access (e.g., `issue.title`)
- Collection objects that are enumerable for easy iteration
- API validation tool for checking model compatibility
- Migration guide for transitioning from hash-based to object model

### Changed
- All client methods now return model objects instead of hash/response pairs
- Model objects retain access to the original response via `_response` attribute
- Improved documentation with examples using the new object model
- Backwards compatibility maintained with previous hash-based approach

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

[1.2.0]: https://github.com/benjodo/pylon-api/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/benjodo/pylon-api/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/benjodo/pylon-api/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/benjodo/pylon-api/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/benjodo/pylon-api/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/benjodo/pylon-api/releases/tag/v0.1.0