# frozen_string_literal: true

module Pylon
  # Client for interacting with the Pylon API
  #
  # @example
  #   client = Pylon::Client.new(api_key: 'your_api_key')
  #   issues = client.list_issues(start_time: '2024-03-01T00:00:00Z', end_time: '2024-03-31T23:59:59Z')
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
    # @return [Array<Hash>] List of accounts
    def list_accounts(page: 1, per_page: 20)
      get("/accounts", query: { page: page, per_page: per_page })
    end

    # Get details for a specific account
    #
    # @param account_id [String] The ID of the account to retrieve
    # @return [Hash] Account details
    def get_account(account_id)
      get("/accounts/#{account_id}")
    end

    # Create a new attachment
    #
    # @param file [String] The file content to upload
    # @return [Hash] Created attachment details
    def create_attachment(file)
      post("/attachments", body: { file: file })
    end

    # Get details for a specific attachment
    #
    # @param attachment_id [String] The ID of the attachment to retrieve
    # @return [Hash] Attachment details
    def get_attachment(attachment_id)
      get("/attachments/#{attachment_id}")
    end

    # List all contacts with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Array<Hash>] List of contacts
    def list_contacts(page: 1, per_page: 20)
      get("/contacts", query: { page: page, per_page: per_page })
    end

    # Create a new contact
    #
    # @param params [Hash] Contact parameters
    # @return [Hash] Created contact details
    def create_contact(params)
      post("/contacts", body: params)
    end

    # Get details for a specific contact
    #
    # @param contact_id [String] The ID of the contact to retrieve
    # @return [Hash] Contact details
    def get_contact(contact_id)
      get("/contacts/#{contact_id}")
    end

    # Update an existing contact
    #
    # @param contact_id [String] The ID of the contact to update
    # @param params [Hash] Updated contact parameters
    # @return [Hash] Updated contact details
    def update_contact(contact_id, params)
      patch("/contacts/#{contact_id}", body: params)
    end

    # List all custom fields with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Array<Hash>] List of custom fields
    def list_custom_fields(page: 1, per_page: 20)
      get("/custom_fields", query: { page: page, per_page: per_page })
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
    # @return [Array<Hash>] List of issues
    # @raise [ArgumentError] If start_time or end_time is missing
    def list_issues(start_time:, end_time:, page: 1, per_page: 20, **filters)
      raise ArgumentError, "start_time is required" unless start_time
      raise ArgumentError, "end_time is required" unless end_time

      get("/issues", query: filters.merge(
        start_time: start_time,
        end_time: end_time,
        page: page,
        per_page: per_page
      ))
    end

    # Create a new issue
    #
    # @param params [Hash] Issue parameters
    # @return [Hash] Created issue details
    def create_issue(params)
      post("/issues", body: params)
    end

    # Get details for a specific issue
    #
    # @param issue_id [String] The ID of the issue to retrieve
    # @return [Hash] Issue details
    def get_issue(issue_id)
      get("/issues/#{issue_id}")
    end

    # Update an existing issue
    #
    # @param issue_id [String] The ID of the issue to update
    # @param params [Hash] Updated issue parameters
    # @return [Hash] Updated issue details
    def update_issue(issue_id, params)
      patch("/issues/#{issue_id}", body: params)
    end

    # List all knowledge base articles with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Array<Hash>] List of articles
    def list_articles(page: 1, per_page: 20)
      get("/knowledge_base/articles", query: { page: page, per_page: per_page })
    end

    # Get details for a specific article
    #
    # @param article_id [String] The ID of the article to retrieve
    # @return [Hash] Article details
    def get_article(article_id)
      get("/knowledge_base/articles/#{article_id}")
    end

    # Get details for the current user
    #
    # @return [Hash] Current user details
    def get_current_user
      get("/me")
    end

    # List all tags with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Array<Hash>] List of tags
    def list_tags(page: 1, per_page: 20)
      get("/tags", query: { page: page, per_page: per_page })
    end

    # Create a new tag
    #
    # @param name [String] The name of the tag
    # @param color [String] Optional hex color code for the tag
    # @return [Hash] Created tag details
    def create_tag(name:, color: nil)
      post("/tags", body: { name: name, color: color }.compact)
    end

    # List all teams with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Array<Hash>] List of teams
    def list_teams(page: 1, per_page: 20)
      get("/teams", query: { page: page, per_page: per_page })
    end

    # Create a new team
    #
    # @param params [Hash] Team parameters
    # @return [Hash] Created team details
    def create_team(params)
      post("/teams", body: params)
    end

    # Get details for a specific team
    #
    # @param team_id [String] The ID of the team to retrieve
    # @return [Hash] Team details
    def get_team(team_id)
      get("/teams/#{team_id}")
    end

    # List all ticket forms with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Array<Hash>] List of ticket forms
    def list_ticket_forms(page: 1, per_page: 20)
      get("/ticket-forms", query: { page: page, per_page: per_page })
    end

    # Create a new ticket form
    #
    # @param name [String] The name of the form
    # @param fields [Array<Hash>] Array of form field definitions
    # @return [Hash] Created ticket form details
    def create_ticket_form(name:, fields: [])
      post("/ticket-forms", body: { name: name, fields: fields })
    end

    # List all user roles with pagination
    #
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @return [Array<Hash>] List of user roles
    def list_user_roles(page: 1, per_page: 20)
      get("/user_roles", query: { page: page, per_page: per_page })
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
    # @return [Array<Hash>] List of users
    def list_users(page: 1, per_page: 20)
      get("/users", query: { page: page, per_page: per_page })
    end

    # Create a new user
    #
    # @param params [Hash] User parameters
    # @return [Hash] Created user details
    def create_user(params)
      post("/users", body: params)
    end

    # Get details for a specific user
    #
    # @param user_id [String] The ID of the user to retrieve
    # @return [Hash] User details
    def get_user(user_id)
      get("/users/#{user_id}")
    end

    # Update an existing user
    #
    # @param user_id [String] The ID of the user to update
    # @param params [Hash] Updated user parameters
    # @return [Hash] Updated user details
    def update_user(user_id, params)
      patch("/users/#{user_id}", body: params)
    end

    private

    # @return [Faraday::Connection] Configured Faraday connection
    def connection
      @connection ||= Faraday.new(@base_url) do |f|
        f.request :json
        f.request :multipart
        f.response :json
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
    # @return [Array] Array containing response data and response object
    # @raise [AuthenticationError] If authentication fails
    # @raise [ResourceNotFoundError] If resource is not found
    # @raise [ValidationError] If request parameters are invalid
    # @raise [ApiError] For other API errors
    def handle_response(response)
      if @debug
        puts "Request URL: #{response.env.url}"
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body.inspect}"
      end

      case response.status
      when 200..299
        data = response.body
        data = data["data"] if data.is_a?(Hash) && data.key?("data")
        [data, response]
      when 401
        raise AuthenticationError, parse_error_message(response)
      when 404
        raise ResourceNotFoundError, parse_error_message(response)
      when 422
        raise ValidationError, parse_error_message(response)
      else
        raise ApiError.new(parse_error_message(response), response)
      end
    end

    # Parse error message from response
    #
    # @param response [Faraday::Response] The API response
    # @return [String] Error message
    def parse_error_message(response)
      if response.body.is_a?(Hash)
        response.body["errors"]&.first || response.body["error"] || "HTTP #{response.status}"
      else
        "HTTP #{response.status}"
      end
    end

    # Make a GET request
    #
    # @param path [String] The API endpoint path
    # @param query [Hash] Query parameters
    # @return [Array] Array containing response data and response object
    def get(path, query: {})
      handle_response(connection.get(path, query))
    end

    # Make a POST request
    #
    # @param path [String] The API endpoint path
    # @param body [Hash] Request body
    # @return [Array] Array containing response data and response object
    def post(path, body: {})
      handle_response(connection.post(path, body.to_json))
    end

    # Make a PATCH request
    #
    # @param path [String] The API endpoint path
    # @param body [Hash] Request body
    # @return [Array] Array containing response data and response object
    def patch(path, body: {})
      handle_response(connection.patch(path, body.to_json))
    end

    # Make a DELETE request
    #
    # @param path [String] The API endpoint path
    # @return [Array] Array containing response data and response object
    def delete(path)
      handle_response(connection.delete(path))
    end
  end
end
