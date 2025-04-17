# frozen_string_literal: true

module Pylon
  # Major version for breaking changes
  MAJOR = 1
  # Minor version for new features
  MINOR = 1
  # Patch version for bug fixes
  PATCH = 0
  # Pre-release version (optional)
  PRE = nil

  # Version string following SemVer
  # @return [String] The current version of the gem
  VERSION = [MAJOR, MINOR, PATCH, PRE].compact.join(".")
end
