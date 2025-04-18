# frozen_string_literal: true

require "faraday"
require "faraday/multipart"
require "json"
require "tempfile"

require_relative "pylon/version"
require_relative "pylon/models/base"
require_relative "pylon/models/collection"
require_relative "pylon/models/user"
require_relative "pylon/models/account"
require_relative "pylon/models/issue"
require_relative "pylon/models/team"
require_relative "pylon/models/tag"
require_relative "pylon/models/attachment"
require_relative "pylon/models/contact"
require_relative "pylon/models/ticket_form"
require_relative "pylon/models/article"
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
