# frozen_string_literal: true

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

  describe "rate limiting" do
    let(:rate_limit_response) do
      {
        "errors" => ["Rate limit exceeded. Please try again in 60 seconds."]
      }
    end

    context "when rate limit is exceeded" do
      before do
        stub_pylon_request(:get, "/me",
                           status: 429,
                           response_body: rate_limit_response,
                           headers: auth_headers.merge(
                             "x-rate-limit-limit" => "100",
                             "x-rate-limit-remaining" => "0",
                             "x-rate-limit-reset" => (Time.now + 60).to_i.to_s
                           ))
      end

      it "raises ApiError with rate limit message" do
        expect do
          client.get_current_user
        end.to raise_error(Pylon::ApiError, "Rate limit exceeded. Please try again in 60 seconds.")
      end
    end

    context "when rate limit headers are present" do
      before do
        stub_pylon_request(:get, "/me",
                           response_body: { "id" => "user_1" },
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "includes rate limit information in response" do
        data, response = client.get_current_user
        expect(data).to eq({ "id" => "user_1" })
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "accounts" do
    describe "#list_accounts" do
      let(:accounts_data) { [{ "id" => "1", "name" => "Test Account" }] }

      before do
        stub_pylon_request(:get, "/accounts",
                           response_body: accounts_data,
                           query: { page: 1, per_page: 20 },
                           headers: auth_headers.merge(rate_limit_headers))
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
                           headers: auth_headers.merge(rate_limit_headers))
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
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "creates an attachment" do
        data, response = client.create_attachment(file)
        expect(data).to eq(attachment_data)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
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
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "creates a contact" do
        data, response = client.create_contact(contact_params)
        expect(data).to eq(contact_response)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "issues" do
    describe "#list_issues" do
      let(:start_time) { "2024-03-14T00:00:00Z" }
      let(:end_time) { "2024-03-14T23:59:59Z" }
      let(:issues_data) do
        [{ "id" => "1", "title" => "Test Issue", "state" => "open", "created_at" => "2024-03-14T12:00:00Z" }]
      end

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
                             headers: auth_headers.merge(rate_limit_headers))
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
          expect do
            client.list_issues(end_time: end_time)
          end.to raise_error(ArgumentError, "missing keyword: :start_time")
        end

        it "raises ArgumentError when end_time is missing" do
          expect do
            client.list_issues(start_time: start_time)
          end.to raise_error(ArgumentError, "missing keyword: :end_time")
        end
      end
    end

    describe "#create_issue" do
      let(:issue_params) { { "title" => "New Issue", "description" => "Test" } }
      let(:issue_response) { issue_params.merge("id" => "1") }

      before do
        stub_pylon_request(:post, "/issues",
                           response_body: issue_response,
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "creates an issue" do
        data, response = client.create_issue(issue_params)
        expect(data).to eq(issue_response)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end

    describe "#snooze_issue" do
      let(:issue_id) { "123" }
      let(:snooze_until) { "2024-04-01T10:00:00Z" }
      let(:snoozed_issue_response) do
        {
          "id" => issue_id,
          "title" => "Test Issue",
          "snoozed_until_time" => snooze_until,
          "state" => "snoozed"
        }
      end

      before do
        stub_pylon_request(:post, "/issues/#{issue_id}/snooze",
                           response_body: snoozed_issue_response,
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "snoozes the issue until the specified time" do
        data, response = client.snooze_issue(issue_id, snooze_until: snooze_until)
        expect(data).to eq(snoozed_issue_response)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
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
                           headers: auth_headers.merge(rate_limit_headers))
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
                           headers: auth_headers.merge(rate_limit_headers))
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
                           headers: auth_headers.merge(rate_limit_headers))
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
      let(:teams_data) { [{ "id" => "team1", "name" => "Engineering" }] }

      before do
        stub_pylon_request(:get, "/teams",
                           response_body: teams_data,
                           query: { page: 1, per_page: 20 },
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "returns teams list and response" do
        data, response = client.list_teams
        expect(data).to eq(teams_data)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end

    describe "#create_team" do
      let(:team_params) { { name: "Engineering" } }
      let(:team_response) { { "id" => "team1", "name" => "Engineering" } }

      before do
        stub_pylon_request(:post, "/teams",
                           response_body: team_response,
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "creates a team and returns response" do
        data, response = client.create_team(team_params)
        expect(data).to eq(team_response)
        expect(response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "error handling" do
    describe "authentication errors" do
      before do
        stub_pylon_request(:get, "/me",
                           status: 401,
                           response_body: { "errors" => ["Invalid API key"] },
                           headers: auth_headers)
      end

      it "raises AuthenticationError" do
        expect { client.get_current_user }.to raise_error(Pylon::AuthenticationError, "Invalid API key")
      end
    end

    describe "not found errors" do
      before do
        stub_pylon_request(:get, "/accounts/999",
                           status: 404,
                           response_body: { "errors" => ["Account not found"] },
                           headers: auth_headers)
      end

      it "raises ResourceNotFoundError" do
        expect { client.get_account("999") }.to raise_error(Pylon::ResourceNotFoundError, "Account not found")
      end
    end

    describe "validation errors" do
      before do
        stub_pylon_request(:post, "/contacts",
                           status: 422,
                           response_body: { "errors" => ["Email is invalid"] },
                           headers: auth_headers)
      end

      it "raises ValidationError" do
        expect { client.create_contact({}) }.to raise_error(Pylon::ValidationError, "Email is invalid")
      end
    end

    describe "other API errors" do
      before do
        stub_pylon_request(:get, "/me",
                           status: 500,
                           response_body: { "errors" => ["Internal server error"] },
                           headers: auth_headers)
      end

      it "raises ApiError" do
        expect { client.get_current_user }.to raise_error(Pylon::ApiError, "Internal server error")
      end
    end
  end
end
