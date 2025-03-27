# frozen_string_literal: true

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

  class ApiError < Error
    attr_reader :response

    def initialize(message = nil, response = nil)
      super(message)
      @response = response
    end
  end
end
