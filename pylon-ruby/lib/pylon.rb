require "faraday"
require "faraday/multipart"
require "json"

require_relative "pylon/version"
require_relative "pylon/client"

module Pylon
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ResourceNotFoundError < Error; end
  class ValidationError < Error; end
  class ApiError < Error; end
end
