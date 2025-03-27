require "spec_helper"

RSpec.describe Pylon::Client do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key: api_key) }
  let(:auth_headers) { { "Authorization" => "Bearer test_api_key" } }
  let(:rate_limit_headers) do
    {
      "x-rate-limit-limit" => "100",
      "x-rate-limit-remaining" => "99",
      "x-rate-limit-reset" => Time.now.to_i.to_s
    }
  end

  describe "#initialize" do
    it "sets the API key" do
      expect(client.api_key).to eq(api_key)
    end

    it "sets debug mode" do
      client = described_class.new(api_key: api_key, debug: true)
      expect(client.debug).to be true
    end
  end

  describe "accounts" do
    describe "#list_accounts" do
      let(:accounts_data) { [{ "id" => "1", "name" => "Test Account" }] }

      before do
        stub_pylon_request(:get, "/accounts",
          response_body: accounts_data,
          query: { page: 1, per_page: 20 },
          headers: auth_headers.merge(rate_limit_headers)
        )
      end

      it "returns accounts list and response" do
        data, response = client.list_accounts
        expect(data).to eq(accounts_data)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end

    describe "#get_account" do
      let(:account_id) { "123" }
      let(:account_data) { { "id" => account_id, "name" => "Test Account" } }

      before do
        stub_pylon_request(:get, "/accounts/#{account_id}",
          response_body: account_data,
          headers: auth_headers.merge(rate_limit_headers)
        )
      end

      it "returns account details and response" do
        data, response = client.get_account(account_id)
        expect(data).to eq(account_data)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "attachments" do
    describe "#create_attachment" do
      let(:file) { "file_content" }
      let(:attachment_data) { { "id" => "1", "url" => "https://example.com/file.pdf" } }

      before do
        stub_pylon_request(:post, "/attachments",
          response_body: attachment_data,
          headers: auth_headers
        )
      end

      it "creates an attachment" do
        expect(client.create_attachment(file)).to eq(attachment_data)
      end
    end
  end

  describe "contacts" do
    describe "#create_contact" do
      let(:contact_params) { { "email" => "test@example.com", "name" => "Test User" } }
      let(:contact_response) { contact_params.merge("id" => "1") }

      before do
        stub_pylon_request(:post, "/contacts",
          response_body: contact_response,
          headers: auth_headers
        )
      end

      it "creates a contact" do
        expect(client.create_contact(contact_params)).to eq(contact_response)
      end
    end
  end

  describe "issues" do
    describe "#list_issues" do
      let(:start_time) { "2024-03-14T00:00:00Z" }
      let(:end_time) { "2024-03-14T23:59:59Z" }
      let(:issues_data) { [{ "id" => "1", "title" => "Test Issue", "state" => "open", "created_at" => "2024-03-14T12:00:00Z" }] }

      context "with valid parameters" do
        before do
          stub_pylon_request(:get, "/issues",
            response_body: issues_data,
            query: {
              start_time: start_time,
              end_time: end_time,
              page: 1,
              per_page: 20,
              status: "open"
            },
            headers: auth_headers.merge(rate_limit_headers)
          )
        end

        it "returns issues list and response" do
          data, response = client.list_issues(
            start_time: start_time,
            end_time: end_time,
            status: "open"
          )
          expect(data).to eq(issues_data)
          expect(response.headers["x-rate-limit-remaining"]).to eq("99")
        end
      end

      context "with missing parameters" do
        it "raises ArgumentError when start_time is missing" do
          expect {
            client.list_issues(end_time: end_time)
          }.to raise_error(ArgumentError, "start_time is required")
        end

        it "raises ArgumentError when end_time is missing" do
          expect {
            client.list_issues(start_time: start_time)
          }.to raise_error(ArgumentError, "end_time is required")
        end
      end
    end

    describe "#create_issue" do
      let(:issue_params) { { "title" => "New Issue", "description" => "Test" } }
      let(:issue_response) { issue_params.merge("id" => "1") }

      before do
        stub_pylon_request(:post, "/issues",
          response_body: issue_response,
          headers: auth_headers
        )
      end

      it "creates an issue" do
        expect(client.create_issue(issue_params)).to eq(issue_response)
      end
    end
  end

  describe "me" do
    describe "#get_current_user" do
      let(:user_data) do
        {
          "id" => "user_1",
          "email" => "me@example.com",
          "name" => "Test User",
          "role" => "admin"
        }
      end

      before do
        stub_pylon_request(:get, "/me",
          response_body: user_data,
          headers: auth_headers.merge(rate_limit_headers)
        )
      end

      it "returns current user details and response" do
        data, response = client.get_current_user
        expect(data).to eq(user_data)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "tags" do
    describe "#list_tags" do
      let(:tags_data) do
        [
          {
            "id" => "tag1",
            "value" => "bug",
            "hex_color" => "#ff0000",
            "object_type" => "issue"
          },
          {
            "id" => "tag2",
            "value" => "feature",
            "hex_color" => "#00ff00",
            "object_type" => "account"
          }
        ]
      end

      before do
        stub_pylon_request(:get, "/tags",
          response_body: tags_data,
          query: { page: 1, per_page: 20 },
          headers: auth_headers.merge(rate_limit_headers)
        )
      end

      it "returns tags list and response" do
        data, response = client.list_tags
        expect(data).to eq(tags_data)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end

    describe "#create_tag" do
      let(:tag_params) { { name: "feature", color: "#00ff00" } }
      let(:tag_response) do
        {
          "id" => "tag1",
          "value" => "feature",
          "hex_color" => "#00ff00",
          "object_type" => "issue"
        }
      end

      before do
        stub_pylon_request(:post, "/tags",
          response_body: tag_response,
          headers: auth_headers.merge(rate_limit_headers)
        )
      end

      it "creates a tag and returns response" do
        data, response = client.create_tag(**tag_params)
        expect(data).to eq(tag_response)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "teams" do
    describe "#list_teams" do
      let(:teams_data) { [{ "id" => "1", "name" => "Support Team" }] }

      before do
        stub_pylon_request(:get, "/teams",
          response_body: teams_data,
          query: { page: 1, per_page: 20 },
          headers: auth_headers
        )
      end

      it "returns teams list" do
        expect(client.list_teams).to eq(teams_data)
      end
    end

    describe "#create_team" do
      let(:team_params) { { "name" => "Engineering" } }
      let(:team_response) { team_params.merge("id" => "1") }

      before do
        stub_pylon_request(:post, "/teams",
          response_body: team_response,
          headers: auth_headers
        )
      end

      it "creates a team" do
        expect(client.create_team(team_params)).to eq(team_response)
      end
    end

    describe "#get_team" do
      let(:team_id) { "123" }
      let(:team_data) { { "id" => team_id, "name" => "Support Team" } }

      before do
        stub_pylon_request(:get, "/teams/#{team_id}",
          response_body: team_data,
          headers: auth_headers
        )
      end

      it "returns team details" do
        expect(client.get_team(team_id)).to eq(team_data)
      end
    end
  end

  describe "ticket_forms" do
    describe "#list_ticket_forms" do
      let(:forms_data) do
        [
          {
            "id" => "form1",
            "name" => "Support Request",
            "fields" => [
              {
                "name" => "severity",
                "type" => "select"
              }
            ]
          }
        ]
      end

      before do
        stub_pylon_request(:get, "/ticket-forms",
          response_body: forms_data,
          query: { page: 1, per_page: 20 },
          headers: auth_headers.merge(rate_limit_headers)
        )
      end

      it "returns ticket forms list and response" do
        data, response = client.list_ticket_forms
        expect(data).to eq(forms_data)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end

    describe "#create_ticket_form" do
      let(:form_params) do
        {
          name: "Bug Report",
          fields: [
            {
              name: "severity",
              type: "select"
            }
          ]
        }
      end

      let(:form_response) do
        {
          "id" => "form1",
          "name" => "Bug Report",
          "fields" => [
            {
              "name" => "severity",
              "type" => "select"
            }
          ]
        }
      end

      before do
        stub_pylon_request(:post, "/ticket-forms",
          response_body: form_response,
          headers: auth_headers.merge(rate_limit_headers)
        )
      end

      it "creates a ticket form and returns response" do
        data, response = client.create_ticket_form(**form_params)
        expect(data).to eq(form_response)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "user_roles" do
    describe "#list_user_roles" do
      let(:roles_data) { [{ "id" => "1", "name" => "admin" }] }

      before do
        stub_pylon_request(:get, "/user_roles",
          response_body: roles_data,
          query: { page: 1, per_page: 20 },
          headers: auth_headers
        )
      end

      it "returns user roles list" do
        expect(client.list_user_roles).to eq(roles_data)
      end
    end

    describe "#get_user_role" do
      let(:role_id) { "123" }
      let(:role_data) { { "id" => role_id, "name" => "admin", "permissions" => ["manage_users"] } }

      before do
        stub_pylon_request(:get, "/user_roles/#{role_id}",
          response_body: role_data,
          headers: auth_headers
        )
      end

      it "returns user role details" do
        expect(client.get_user_role(role_id)).to eq(role_data)
      end
    end
  end

  describe "users" do
    describe "#list_users" do
      let(:users_data) { [{ "id" => "1", "email" => "user@example.com" }] }

      before do
        stub_pylon_request(:get, "/users",
          response_body: users_data,
          query: { page: 1, per_page: 20 },
          headers: auth_headers
        )
      end

      it "returns users list" do
        expect(client.list_users).to eq(users_data)
      end
    end

    describe "#create_user" do
      let(:user_params) { { "email" => "new@example.com", "name" => "New User" } }
      let(:user_response) { user_params.merge("id" => "1") }

      before do
        stub_pylon_request(:post, "/users",
          response_body: user_response,
          headers: auth_headers
        )
      end

      it "creates a user" do
        expect(client.create_user(user_params)).to eq(user_response)
      end
    end

    describe "#get_user" do
      let(:user_id) { "123" }
      let(:user_data) { { "id" => user_id, "email" => "user@example.com" } }

      before do
        stub_pylon_request(:get, "/users/#{user_id}",
          response_body: user_data,
          headers: auth_headers
        )
      end

      it "returns user details" do
        expect(client.get_user(user_id)).to eq(user_data)
      end
    end

    describe "#update_user" do
      let(:user_id) { "123" }
      let(:user_params) { { "name" => "Updated Name" } }
      let(:user_response) { { "id" => user_id, "name" => "Updated Name", "email" => "user@example.com" } }

      before do
        stub_pylon_request(:patch, "/users/#{user_id}",
          response_body: user_response,
          headers: auth_headers
        )
      end

      it "updates a user" do
        expect(client.update_user(user_id, user_params)).to eq(user_response)
      end
    end
  end

  describe "error handling" do
    describe "when API key is invalid" do
      let(:invalid_client) { described_class.new(api_key: "invalid_key") }

      before do
        stub_pylon_request(:get, "/me",
          status: 401,
          response_body: { "error" => "Invalid API key" },
          headers: { "Authorization" => "Bearer invalid_key" }
        )
      end

      it "raises AuthenticationError" do
        expect { invalid_client.get_current_user }.to raise_error(Pylon::AuthenticationError)
      end
    end

    describe "when resource is not found" do
      before do
        stub_pylon_request(:get, "/issues/invalid",
          status: 404,
          response_body: { "error" => "Not found" },
          headers: auth_headers
        )
      end

      it "raises ResourceNotFoundError" do
        expect { client.get_issue("invalid") }.to raise_error(Pylon::ResourceNotFoundError)
      end
    end

    describe "when validation fails" do
      before do
        stub_pylon_request(:post, "/issues",
          status: 422,
          response_body: { "message" => "Invalid params" },
          headers: auth_headers
        )
      end

      it "raises ValidationError" do
        expect { client.create_issue({}) }.to raise_error(Pylon::ValidationError, "Invalid params")
      end
    end

    describe "rate limiting" do
      let(:rate_limit_response) do
        {
          "errors" => ["Rate limit exceeded"],
          "request_id" => "123"
        }
      end

      before do
        stub_pylon_request(:get, "/me",
          response_body: rate_limit_response,
          status: 429,
          headers: auth_headers.merge(
            "x-rate-limit-limit" => "100",
            "x-rate-limit-remaining" => "0",
            "x-rate-limit-reset" => (Time.now.to_i + 60).to_s
          )
        )
      end

      it "handles rate limit errors" do
        expect {
          client.get_current_user
        }.to raise_error(Pylon::ApiError) do |error|
          expect(error.response.status).to eq(429)
          expect(error.response.headers["x-rate-limit-remaining"]).to eq("0")
        end
      end
    end
  end
end
