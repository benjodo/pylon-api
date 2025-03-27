require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
  primary_coverage :branch
end

require "pylon"
require "webmock/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def stub_pylon_request(method, path, response_body: {}, query: {}, headers: {}, status: 200)
  # Default request headers that should be present in all requests
  default_request_headers = {
    "Accept" => "application/json",
    "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
    "Content-Type" => "application/json",
    "User-Agent" => "Faraday v2.12.2",
    "Authorization" => "Bearer test_api_key"
  }

  # Extract rate limit headers from request headers if present
  response_headers = {
    "Content-Type" => "application/json"
  }

  # Move rate limit headers from request to response headers
  ["x-rate-limit-limit", "x-rate-limit-remaining", "x-rate-limit-reset"].each do |header|
    if headers[header]
      response_headers[header] = headers[header]
      headers.delete(header)
    end
  end

  # Merge default headers with provided headers
  request_headers = default_request_headers.merge(headers)

  stub = stub_request(method, "https://api.usepylon.com#{path}")
  stub = stub.with(query: query) if query.any?
  stub = stub.with(headers: request_headers)

  stub.to_return(
    status: status,
    body: response_body.to_json,
    headers: response_headers
  )
end
