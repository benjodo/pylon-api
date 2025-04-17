# frozen_string_literal: true

module Pylon
  # Client for interacting with the Pylon API
  #
  # @example
  #   client = Pylon::Client.new(api_key: 'your_api_key')
  #   issues = client.list_issues(start_time: '2024-03-01T00:00:00Z', end_time: '2024-03-31T23:59:59Z')
  #   issues.each { |issue| puts issue.title }
  class Client
    # Base URL for the Pylon API
    BASE_URL = "https://api.usepylon.com"

    # @return [String] The API key used for authentication
    attr_reader :api_key, :debug

    # Initialize a new Pylon API client
    #
    # @param api_key [String] Your Pylon API key
    # @param base_url [String] Optional base URL for the API (defaults to production)
    # @param debug [Boolean] Whether to enable debug mode for request/response logging
    def initialize(api_key:, base_url: BASE_URL, debug: false)
      @api_key = api_key
      @base_url = base_url
      @debug = debug
    end

    # List all accounts with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection<Models::Account>] Collection of account objects
    def list_accounts(page: 1, per_page: 20)
      get("/accounts", query: { page: page, per_page: per_page }, 
          model_class: Models::Account, collection: true)
    end

    # Get details for a specific account
    #
    # @param account_id [String] The ID of the account to retrieve
    # @return [Models::Account] Account object
    def get_account(account_id)
      get("/accounts/#{account_id}", model_class: Models::Account)
    end

    # Create a new attachment
    #
    # @param file [String] The file content to upload
    # @return [Models::Attachment] Created attachment object
    def create_attachment(file)
      post("/attachments", body: { file: file }, model_class: Models::Attachment)
    end

    # Get details for a specific attachment
    #
    # @param attachment_id [String] The ID of the attachment to retrieve
    # @return [Models::Attachment] Attachment object
    def get_attachment(attachment_id)
      get("/attachments/#{attachment_id}", model_class: Models::Attachment)
    end

    # List all contacts with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection<Models::Contact>] Collection of contact objects
    def list_contacts(page: 1, per_page: 20)
      get("/contacts", query: { page: page, per_page: per_page }, 
          model_class: Models::Contact, collection: true)
    end

    # Create a new contact
    #
    # @param params [Hash] Contact parameters
    # @return [Models::Contact] Created contact object
    def create_contact(params)
      post("/contacts", body: params, model_class: Models::Contact)
    end

    # Get details for a specific contact
    #
    # @param contact_id [String] The ID of the contact to retrieve
    # @return [Models::Contact] Contact object
    def get_contact(contact_id)
      get("/contacts/#{contact_id}", model_class: Models::Contact)
    end

    # Update an existing contact
    #
    # @param contact_id [String] The ID of the contact to update
    # @param params [Hash] Updated contact parameters
    # @return [Models::Contact] Updated contact object
    def update_contact(contact_id, params)
      patch("/contacts/#{contact_id}", body: params, model_class: Models::Contact)
    end

    # List all custom fields with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection] Collection of custom fields
    def list_custom_fields(page: 1, per_page: 20)
      get("/custom_fields", query: { page: page, per_page: per_page }, collection: true)
    end

    # Create a new custom field
    #
    # @param params [Hash] Custom field parameters
    # @return [Hash] Created custom field details
    def create_custom_field(params)
      post("/custom_fields", body: params)
    end

    # Lists issues within a specified time range (max 30 days)
    #
    # @param start_time [String] Start time in RFC3339 format
    # @param end_time [String] End time in RFC3339 format
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @param filters [Hash] Additional filters to apply
    # @return [Models::Collection<Models::Issue>] Collection of issue objects
    # @raise [ArgumentError] If start_time or end_time is missing
    def list_issues(start_time:, end_time:, page: 1, per_page: 20, **filters)
      raise ArgumentError, "start_time is required" unless start_time
      raise ArgumentError, "end_time is required" unless end_time

      get("/issues", query: filters.merge(
        start_time: start_time,
        end_time: end_time,
        page: page,
        per_page: per_page
      ), model_class: Models::Issue, collection: true)
    end

    # Create a new issue
    #
    # @param params [Hash] Issue parameters
    # @return [Models::Issue] Created issue object
    def create_issue(params)
      post("/issues", body: params, model_class: Models::Issue)
    end

    # Get details for a specific issue
    #
    # @param issue_id [String] The ID of the issue to retrieve
    # @return [Models::Issue] Issue object
    def get_issue(issue_id)
      get("/issues/#{issue_id}", model_class: Models::Issue)
    end

    # Update an existing issue
    #
    # @param issue_id [String] The ID of the issue to update
    # @param params [Hash] Updated issue parameters
    # @return [Models::Issue] Updated issue object
    def update_issue(issue_id, params)
      patch("/issues/#{issue_id}", body: params, model_class: Models::Issue)
    end

    # Snooze an issue until a specified time
    #
    # @param issue_id [String] The ID or number of the issue to snooze
    # @param snooze_until [String] The date and time to snooze the issue until (RFC3339 format)
    # @return [Models::Issue] Updated issue object
    def snooze_issue(issue_id, snooze_until:)
      post("/issues/#{issue_id}/snooze", body: { snooze_until: snooze_until }, 
          model_class: Models::Issue)
    end

    # List all knowledge base articles with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection<Models::Article>] Collection of article objects
    def list_articles(page: 1, per_page: 20)
      get("/knowledge_base/articles", query: { page: page, per_page: per_page }, 
          model_class: Models::Article, collection: true)
    end

    # Get details for a specific article
    #
    # @param article_id [String] The ID of the article to retrieve
    # @return [Models::Article] Article object
    def get_article(article_id)
      get("/knowledge_base/articles/#{article_id}", model_class: Models::Article)
    end

    # Get details for the current user
    #
    # @return [Models::User] Current user object
    def get_current_user
      get("/me", model_class: Models::User)
    end

    # List all tags with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection<Models::Tag>] Collection of tag objects
    def list_tags(page: 1, per_page: 20)
      get("/tags", query: { page: page, per_page: per_page }, 
          model_class: Models::Tag, collection: true)
    end

    # Create a new tag
    #
    # @param name [String] The name of the tag
    # @param color [String] Optional hex color code for the tag
    # @return [Models::Tag] Created tag object
    def create_tag(name:, color: nil)
      post("/tags", body: { name: name, color: color }.compact, model_class: Models::Tag)
    end

    # List all teams with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection<Models::Team>] Collection of team objects
    def list_teams(page: 1, per_page: 20)
      get("/teams", query: { page: page, per_page: per_page }, 
          model_class: Models::Team, collection: true)
    end

    # Create a new team
    #
    # @param params [Hash] Team parameters
    # @return [Models::Team] Created team object
    def create_team(params)
      post("/teams", body: params, model_class: Models::Team)
    end

    # Get details for a specific team
    #
    # @param team_id [String] The ID of the team to retrieve
    # @return [Models::Team] Team object
    def get_team(team_id)
      get("/teams/#{team_id}", model_class: Models::Team)
    end

    # List all ticket forms with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection<Models::TicketForm>] Collection of ticket form objects
    def list_ticket_forms(page: 1, per_page: 20)
      get("/ticket-forms", query: { page: page, per_page: per_page }, 
          model_class: Models::TicketForm, collection: true)
    end

    # Create a new ticket form
    #
    # @param name [String] The name of the form
    # @param fields [Array<Hash>] Array of form field definitions
    # @return [Models::TicketForm] Created ticket form object
    def create_ticket_form(name:, fields: [])
      post("/ticket-forms", body: { name: name, fields: fields }, model_class: Models::TicketForm)
    end

    # List all user roles with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection] Collection of user role objects
    def list_user_roles(page: 1, per_page: 20)
      get("/user_roles", query: { page: page, per_page: per_page }, collection: true)
    end

    # Get details for a specific user role
    #
    # @param role_id [String] The ID of the role to retrieve
    # @return [Hash] Role details
    def get_user_role(role_id)
      get("/user_roles/#{role_id}")
    end

    # List all users with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Models::Collection<Models::User>] Collection of user objects
    def list_users(page: 1, per_page: 20)
      get("/users", query: { page: page, per_page: per_page }, 
          model_class: Models::User, collection: true)
    end

    # Create a new user
    #
    # @param params [Hash] User parameters
    # @return [Models::User] Created user object
    def create_user(params)
      post("/users", body: params, model_class: Models::User)
    end

    # Get details for a specific user
    #
    # @param user_id [String] The ID of the user to retrieve
    # @return [Models::User] User object
    def get_user(user_id)
      get("/users/#{user_id}", model_class: Models::User)
    end

    # Update an existing user
    #
    # @param user_id [String] The ID of the user to update
    # @param params [Hash] Updated user parameters
    # @return [Models::User] Updated user object
    def update_user(user_id, params)
      patch("/users/#{user_id}", body: params, model_class: Models::User)
    end

    private

    # @return [Faraday::Connection] Configured Faraday connection
    def connection
      @connection ||= Faraday.new(@base_url) do |f|
        f.request :json
        f.request :multipart
        f.response :json, content_type: /\bjson$/
        f.response :logger if @debug
        f.adapter Faraday.default_adapter
        f.headers["Authorization"] = "Bearer #{api_key}"
        f.headers["Content-Type"] = "application/json"
        f.headers["Accept"] = "application/json"
      end
    end

    # Handle API response and raise appropriate errors
    #
    # @param response [Faraday::Response] The API response
    # @param model_class [Class] The model class to use for wrapping the response
    # @param collection [Boolean] Whether the response is a collection of items
    # @return [Models::Base, Models::Collection, Array] Model, Collection, or response data array
    # @raise [AuthenticationError] If authentication fails
    # @raise [ResourceNotFoundError] If resource is not found
    # @raise [ValidationError] If request parameters are invalid
    # @raise [ApiError] For other API errors
    def handle_response(response, model_class = nil, collection = false)
      if @debug
        puts "Request URL: #{response.env.url}"
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body.inspect}"
      end

      handle_successful_response(response, model_class, collection) if response.status.between?(200, 299)
      handle_error_response(response)
    end

    # Handle successful API response
    #
    # @param response [Faraday::Response] The API response
    # @param model_class [Class] The model class to use for wrapping the response
    # @param collection [Boolean] Whether the response is a collection of items
    # @return [Models::Base, Models::Collection, Array] Wrapped response data
    def handle_successful_response(response, model_class, collection)
      data = response.body
      data = data["data"] if data.is_a?(Hash) && data.key?("data")
      
      if model_class
        if collection
          Models::Collection.new(data, model_class, response)
        else
          model_class.new(data, response)
        end
      else
        [data, response]
      end
    end

    # Handle error API response
    #
    # @param response [Faraday::Response] The API response
    # @raise [AuthenticationError] If authentication fails
    # @raise [ResourceNotFoundError] If resource is not found
    # @raise [ValidationError] If request parameters are invalid
    # @raise [ApiError] For other API errors
    def handle_error_response(response)
      case response.status
      when 401
        raise AuthenticationError, parse_error_message(response) || "Invalid API key"
      when 404
        raise ResourceNotFoundError, parse_error_message(response) || "Resource not found"
      when 422
        raise ValidationError, parse_error_message(response) || "Validation error"
      when 429
        raise ApiError, parse_error_message(response) || "Rate limit exceeded"
      else
        raise ApiError.new(parse_error_message(response) || "Internal server error", response)
      end
    end

    # Parse error message from response
    #
    # @param response [Faraday::Response] The API response
    # @return [String] Error message
    def parse_error_message(response)
      return nil unless response.body.is_a?(Hash)

      if response.body["errors"].is_a?(Array) && !response.body["errors"].empty?
        response.body["errors"].first
      elsif response.body["error"].is_a?(String)
        response.body["error"]
      end
    end

    # Make a GET request
    #
    # @param path [String] The API endpoint path
    # @param query [Hash] Query parameters
    # @param model_class [Class] The model class to use for wrapping the response
    # @param collection [Boolean] Whether the response is a collection of items
    # @return [Models::Base, Models::Collection, Array] Model, Collection, or response data array
    def get(path, query: {}, model_class: nil, collection: false)
      handle_response(connection.get(path, query), model_class, collection)
    end

    # Make a POST request
    #
    # @param path [String] The API endpoint path
    # @param body [Hash] Request body
    # @param model_class [Class] The model class to use for wrapping the response
    # @param collection [Boolean] Whether the response is a collection of items
    # @return [Models::Base, Models::Collection, Array] Model, Collection, or response data array
    def post(path, body: {}, model_class: nil, collection: false)
      handle_response(connection.post(path, body.to_json), model_class, collection)
    end

    # Make a PATCH request
    #
    # @param path [String] The API endpoint path
    # @param body [Hash] Request body
    # @param model_class [Class] The model class to use for wrapping the response
    # @param collection [Boolean] Whether the response is a collection of items
    # @return [Models::Base, Models::Collection, Array] Model, Collection, or response data array
    def patch(path, body: {}, model_class: nil, collection: false)
      handle_response(connection.patch(path, body.to_json), model_class, collection)
    end

    # Make a DELETE request
    #
    # @param path [String] The API endpoint path
    # @param model_class [Class] The model class to use for wrapping the response
    # @param collection [Boolean] Whether the response is a collection of items
    # @return [Models::Base, Models::Collection, Array] Model, Collection, or response data array
    def delete(path, model_class: nil, collection: false)
      handle_response(connection.delete(path), model_class, collection)
    end
  end
end