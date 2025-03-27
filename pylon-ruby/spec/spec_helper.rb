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

def stub_pylon_request(method, path, response_body: nil, status: 200, query: nil, headers: {})
  default_request_headers = {
    "Accept" => "application/json",
    "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
    "Content-Type" => "application/json",
    "User-Agent" => "Faraday v2.12.2"
  }

  stub = stub_request(method, "https://api.usepylon.com/v1#{path}")
  stub = stub.with(
    headers: default_request_headers.merge(headers),
    query: query
  )
  
  stub.to_return(
    status: status,
    body: response_body.to_json,
    headers: { "Content-Type" => "application/json" }
  )
end
