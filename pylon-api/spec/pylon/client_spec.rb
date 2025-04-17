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

  def stub_pylon_request(method, path, response_body: {}, status: 200, query: {}, headers: {})
    request_headers = {
      "Accept" => "application/json",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Content-Type" => "application/json",
      "User-Agent" => "Faraday v1.10.4",
      "Authorization" => "Bearer test_api_key"
    }

    response_headers = headers.merge(rate_limit_headers).merge("Content-Type" => "application/json")

    url = "https://api.usepylon.com#{path}"
    url += "?#{URI.encode_www_form(query)}" unless query.empty?

    stub_request(method, url)
      .with(
        headers: request_headers
      )
      .to_return(
        status: status,
        body: response_body.to_json,
        headers: response_headers
      )
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

  describe "models" do
    describe "Base model" do
      it "provides attribute access" do
        model = Pylon::Models::Base.new({"id" => "123", "name" => "Test"})
        expect(model.id).to eq("123")
        expect(model.name).to eq("Test")
        expect(model["id"]).to eq("123")
        expect(model.to_h).to eq({"id" => "123", "name" => "Test"})
      end
    end
    
    describe "Collection" do
      it "acts as an enumerable" do
        data = [{"id" => "1"}, {"id" => "2"}]
        collection = Pylon::Models::Collection.new(data, Pylon::Models::Base)
        
        expect(collection.size).to eq(2)
        expect(collection[0].id).to eq("1")
        expect(collection.map(&:id)).to eq(["1", "2"])
      end
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

      it "returns accounts collection" do
        accounts = client.list_accounts
        expect(accounts).to be_a(Pylon::Models::Collection)
        expect(accounts.size).to eq(1)
        expect(accounts[0]).to be_a(Pylon::Models::Account)
        expect(accounts[0].id).to eq("1")
        expect(accounts[0].name).to eq("Test Account")
        expect(accounts._response.headers["x-rate-limit-remaining"]).to eq("99")
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

      it "returns account object" do
        account = client.get_account(account_id)
        expect(account).to be_a(Pylon::Models::Account)
        expect(account.id).to eq(account_id)
        expect(account.name).to eq("Test Account")
        expect(account._response.headers["x-rate-limit-remaining"]).to eq("99")
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
        attachment = client.create_attachment(file)
        expect(attachment).to be_a(Pylon::Models::Attachment)
        expect(attachment.id).to eq("1")
        expect(attachment.url).to eq("https://example.com/file.pdf")
        expect(attachment._response.headers["x-rate-limit-remaining"]).to eq("99")
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
        contact = client.create_contact(contact_params)
        expect(contact).to be_a(Pylon::Models::Contact)
        expect(contact.id).to eq("1")
        expect(contact.email).to eq("test@example.com")
        expect(contact.name).to eq("Test User")
        expect(contact._response.headers["x-rate-limit-remaining"]).to eq("99")
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

        # rubocop:disable RSpec/ExampleLength
        it "returns issues collection with correctly structured objects" do
          issues = client.list_issues(
            start_time: start_time,
            end_time: end_time,
            status: "open"
          )
          expect(issues).to be_a(Pylon::Models::Collection)
          expect(issues.size).to eq(1)
          expect(issues._response.headers["x-rate-limit-remaining"]).to eq("99")
          
          issue = issues[0]
          expect(issue).to be_a(Pylon::Models::Issue)
          expect(issue.id).to eq("1")
          expect(issue.title).to eq("Test Issue")
          expect(issue.state).to eq("open")
        end
        # rubocop:enable RSpec/ExampleLength
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
        issue = client.create_issue(issue_params)
        expect(issue).to be_a(Pylon::Models::Issue)
        expect(issue.id).to eq("1")
        expect(issue.title).to eq("New Issue")
        expect(issue.description).to eq("Test")
        expect(issue._response.headers["x-rate-limit-remaining"]).to eq("99")
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
        issue = client.snooze_issue(issue_id, snooze_until: snooze_until)
        expect(issue).to be_a(Pylon::Models::Issue)
        expect(issue.id).to eq(issue_id)
        expect(issue.state).to eq("snoozed")
        expect(issue.snoozed_until_time).to eq(snooze_until)
        expect(issue._response.headers["x-rate-limit-remaining"]).to eq("99")
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

      it "returns current user object" do
        user = client.get_current_user
        expect(user).to be_a(Pylon::Models::User)
        expect(user.id).to eq("user_1")
        expect(user.email).to eq("me@example.com")
        expect(user.name).to eq("Test User")
        expect(user.role).to eq("admin")
        expect(user._response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "tags" do
    describe "#list_tags" do
      let(:tags_data) { [{ "id" => "1", "name" => "Test Tag" }] }

      before do
        stub_pylon_request(:get, "/tags",
                           response_body: tags_data,
                           query: { page: 1, per_page: 20 },
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "returns tags collection" do
        tags = client.list_tags
        expect(tags).to be_a(Pylon::Models::Collection)
        expect(tags.size).to eq(1)
        expect(tags[0]).to be_a(Pylon::Models::Tag)
        expect(tags[0].id).to eq("1")
        expect(tags[0].name).to eq("Test Tag")
        expect(tags._response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end

    describe "#create_tag" do
      let(:tag_params) { { name: "Test Tag", color: "#FF0000" } }
      let(:tag_response) { { "id" => "1", "name" => "Test Tag", "color" => "#FF0000" } }

      before do
        stub_pylon_request(:post, "/tags",
                           response_body: tag_response,
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "creates a tag" do
        tag = client.create_tag(**tag_params)
        expect(tag).to be_a(Pylon::Models::Tag)
        expect(tag.id).to eq("1")
        expect(tag.name).to eq("Test Tag")
        expect(tag.color).to eq("#FF0000")
        expect(tag._response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end
  end

  describe "teams" do
    describe "#list_teams" do
      let(:teams_data) { [{ "id" => "1", "name" => "Engineering" }] }

      before do
        stub_pylon_request(:get, "/teams",
                           response_body: teams_data,
                           query: { page: 1, per_page: 20 },
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "returns teams collection" do
        teams = client.list_teams
        expect(teams).to be_a(Pylon::Models::Collection)
        expect(teams.size).to eq(1)
        expect(teams[0]).to be_a(Pylon::Models::Team)
        expect(teams[0].id).to eq("1")
        expect(teams[0].name).to eq("Engineering")
        expect(teams._response.headers["x-rate-limit-remaining"]).to eq("99")
      end
    end

    describe "#create_team" do
      let(:team_params) { { "name" => "Engineering" } }
      let(:team_response) { team_params.merge("id" => "1") }

      before do
        stub_pylon_request(:post, "/teams",
                           response_body: team_response,
                           headers: auth_headers.merge(rate_limit_headers))
      end

      it "creates a team" do
        team = client.create_team(team_params)
        expect(team).to be_a(Pylon::Models::Team)
        expect(team.id).to eq("1")
        expect(team.name).to eq("Engineering")
        expect(team._response.headers["x-rate-limit-remaining"]).to eq("99")
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