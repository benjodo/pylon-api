module Pylon
  class Client
    BASE_URL = "https://api.usepylon.com"

    attr_reader :api_key

    def initialize(api_key:, base_url: BASE_URL, debug: false)
      @api_key = api_key
      @base_url = base_url
      @debug = debug
    end

    # Accounts
    def list_accounts(page: 1, per_page: 20)
      get("/accounts", query: { page: page, per_page: per_page })
    end

    def get_account(account_id)
      get("/accounts/#{account_id}")
    end

    # Attachments
    def create_attachment(file)
      post("/attachments", body: { file: file })
    end

    def get_attachment(attachment_id)
      get("/attachments/#{attachment_id}")
    end

    # Contacts
    def list_contacts(page: 1, per_page: 20)
      get("/contacts", query: { page: page, per_page: per_page })
    end

    def create_contact(params)
      post("/contacts", body: params)
    end

    def get_contact(contact_id)
      get("/contacts/#{contact_id}")
    end

    def update_contact(contact_id, params)
      patch("/contacts/#{contact_id}", body: params)
    end

    # Custom Fields
    def list_custom_fields(page: 1, per_page: 20)
      get("/custom_fields", query: { page: page, per_page: per_page })
    end

    def create_custom_field(params)
      post("/custom_fields", body: params)
    end

    # Issues
    # Lists issues within a specified time range (max 30 days)
    # @param start_time [String] Start time in RFC3339 format
    # @param end_time [String] End time in RFC3339 format
    # @param page [Integer] Page number for pagination
    # @param per_page [Integer] Number of items per page
    # @param filters [Hash] Additional filters to apply
    # @return [Hash] List of issues
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

    def create_issue(params)
      post("/issues", body: params)
    end

    def get_issue(issue_id)
      get("/issues/#{issue_id}")
    end

    def update_issue(issue_id, params)
      patch("/issues/#{issue_id}", body: params)
    end

    # Knowledge Base
    def list_articles(page: 1, per_page: 20)
      get("/knowledge_base/articles", query: { page: page, per_page: per_page })
    end

    def get_article(article_id)
      get("/knowledge_base/articles/#{article_id}")
    end

    # Me (Current User)
    def get_current_user
      get("/me")
    end

    # Tags
    def list_tags(page: 1, per_page: 20)
      get("/tags", query: { page: page, per_page: per_page })
    end

    def create_tag(name:, color: nil)
      post("/tags", body: { name: name, color: color }.compact)
    end

    # Teams
    def list_teams(page: 1, per_page: 20)
      get("/teams", query: { page: page, per_page: per_page })
    end

    def create_team(params)
      post("/teams", body: params)
    end

    def get_team(team_id)
      get("/teams/#{team_id}")
    end

    # Ticket Forms
    def list_ticket_forms(page: 1, per_page: 20)
      get("/ticket-forms", query: { page: page, per_page: per_page })
    end

    def create_ticket_form(name:, fields: [])
      post("/ticket-forms", body: { name: name, fields: fields })
    end

    # User Roles
    def list_user_roles(page: 1, per_page: 20)
      get("/user_roles", query: { page: page, per_page: per_page })
    end

    def get_user_role(role_id)
      get("/user_roles/#{role_id}")
    end

    # Users
    def list_users(page: 1, per_page: 20)
      get("/users", query: { page: page, per_page: per_page })
    end

    def create_user(params)
      post("/users", body: params)
    end

    def get_user(user_id)
      get("/users/#{user_id}")
    end

    def update_user(user_id, params)
      patch("/users/#{user_id}", body: params)
    end

    private

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

    def handle_response(response)
      if @debug
        puts "Request URL: #{response.env.url}"
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body.inspect}"
      end

      case response.status
      when 200..299
        data = response.body
        data = data['data'] if data.is_a?(Hash) && data.key?('data')
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

    def parse_error_message(response)
      if response.body.is_a?(Hash)
        response.body['errors']&.first || response.body['error'] || "HTTP #{response.status}"
      else
        "HTTP #{response.status}"
      end
    end

    def get(path, query: {})
      handle_response(connection.get(path, query))
    end

    def post(path, body: {})
      handle_response(connection.post(path, body.to_json))
    end

    def patch(path, body: {})
      handle_response(connection.patch(path, body.to_json))
    end

    def delete(path)
      handle_response(connection.delete(path))
    end
  end
end
