# frozen_string_literal: true

require "pylon"
require "csv"
require "json"

# This script validates that our object models match the actual API responses
# Usage: PYLON_API_KEY=your_key ruby examples/api_validation.rb

class ApiValidator
  def initialize(api_key)
    @client = Pylon::Client.new(api_key: api_key)
    @results = []
  end

  def run_validations
    puts "== Pylon API Validation =="
    puts "Running validations against live API..."

    validate_user
    validate_accounts
    validate_issues
    validate_teams
    validate_tags

    # Generate report
    print_report
  end

  private

  def validate_user
    begin
      print "Validating current user... "
      user = @client.get_current_user
      @results << {
        endpoint: "/me",
        model: "User",
        object_attributes: user.attributes.keys.sort,
        status: "Success"
      }
      print "✅\n"
    rescue => e
      record_error("/me", "User", e)
      print "❌\n"
    end
  end

  def validate_accounts
    begin
      print "Validating accounts... "
      accounts = @client.list_accounts(per_page: 1)
      @results << {
        endpoint: "/accounts",
        model: "Account",
        object_attributes: accounts.size > 0 ? accounts[0].attributes.keys.sort : [],
        status: "Success"
      }
      print "✅\n"
    rescue => e
      record_error("/accounts", "Account", e)
      print "❌\n"
    end
  end

  def validate_issues
    begin
      print "Validating issues... "
      # Get issues from the last 30 days
      start_time = (Time.now - 30 * 24 * 60 * 60).iso8601
      end_time = Time.now.iso8601
      issues = @client.list_issues(start_time: start_time, end_time: end_time, per_page: 1)
      
      @results << {
        endpoint: "/issues",
        model: "Issue",
        object_attributes: issues.size > 0 ? issues[0].attributes.keys.sort : [],
        status: "Success"
      }
      print "✅\n"
    rescue => e
      record_error("/issues", "Issue", e)
      print "❌\n"
    end
  end

  def validate_teams
    begin
      print "Validating teams... "
      teams = @client.list_teams(per_page: 1)
      @results << {
        endpoint: "/teams",
        model: "Team",
        object_attributes: teams.size > 0 ? teams[0].attributes.keys.sort : [],
        status: "Success"
      }
      print "✅\n"
    rescue => e
      record_error("/teams", "Team", e)
      print "❌\n"
    end
  end

  def validate_tags
    begin
      print "Validating tags... "
      tags = @client.list_tags(per_page: 1)
      @results << {
        endpoint: "/tags",
        model: "Tag",
        object_attributes: tags.size > 0 ? tags[0].attributes.keys.sort : [],
        status: "Success"
      }
      print "✅\n"
    rescue => e
      record_error("/tags", "Tag", e)
      print "❌\n"
    end
  end

  def record_error(endpoint, model, error)
    @results << {
      endpoint: endpoint,
      model: model,
      object_attributes: [],
      status: "Error: #{error.class} - #{error.message}"
    }
  end

  def print_report
    puts "\n== Validation Report =="
    
    print_errors
    print_model_fields
    save_results_to_file
    print_summary
  end

  def print_errors
    errors = @results.select { |r| r[:status].start_with?("Error") }
    return unless errors.any?

    puts "\n❌ #{errors.size} validation(s) failed:"
    errors.each do |error|
      puts "- #{error[:endpoint]} (#{error[:model]}): #{error[:status]}"
    end
  end

  def print_model_fields
    puts "\nModel Field Validation:"
    successful_results = @results.select do |r| 
      !r[:status].start_with?("Error") && !r[:object_attributes].empty?
    end

    successful_results.each do |result|
      puts "- #{result[:model]} (#{result[:endpoint]}):"
      puts "  Fields: #{result[:object_attributes].join(', ')}"
      puts ""
    end
  end

  def save_results_to_file
    File.write("api_validation_results.json", JSON.pretty_generate(@results))
    puts "Detailed results saved to api_validation_results.json"
  end

  def print_summary
    errors = @results.select { |r| r[:status].start_with?("Error") }
    if errors.empty?
      puts "\n✅ All validations passed successfully!"
    else
      puts "\n⚠️ Some validations failed. Please check the errors above."
    end
  end
end

if ENV["PYLON_API_KEY"].nil? || ENV["PYLON_API_KEY"].empty?
  puts "ERROR: You must set the PYLON_API_KEY environment variable."
  puts "Usage: PYLON_API_KEY=your_key ruby examples/api_validation.rb"
  exit 1
end

validator = ApiValidator.new(ENV["PYLON_API_KEY"])
validator.run_validations