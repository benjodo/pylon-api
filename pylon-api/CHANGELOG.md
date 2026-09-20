# Changelog

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

## [1.1.0] - 2025-04-17

### Added
- Support for URL-based file attachments
- Enhanced attachment handling for various file types
- Added MIME type detection for file uploads

## [1.0.0] - 2024-03-21

### Changed
- Downgraded Faraday dependency from 2.12.2 to 1.10.4 for better compatibility with existing applications
- Updated Faraday multipart and retry dependencies to match Faraday 1.x compatibility

## [0.2.0] - 2024-03-21

### Added
- Added support for file uploads via multipart/form-data
- Added retry mechanism for failed requests
- Added comprehensive error handling and logging

### Changed
- Improved request/response logging
- Enhanced error messages and documentation

## [0.1.0] - 2024-03-20

### Added
- Initial release
- Basic API client functionality
- Support for core API endpoints 