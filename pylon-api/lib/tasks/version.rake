# frozen_string_literal: true

require "date"

namespace :version do
  desc "Display current version"
  task :show do
    require_relative "../pylon/version"
    puts "Current version: #{Pylon::VERSION}"
  end

  %w[major minor patch].each do |part|
    desc "Bump #{part} version"
    task part.to_sym do
      require_relative "../pylon/version"

      # Read version.rb
      version_file = File.read("lib/pylon/version.rb")

      # Update the version constant
      current_value = Pylon.const_get(part.upcase)
      new_value = current_value + 1

      # Reset lower-order versions for major/minor bumps
      case part
      when "major"
        version_file.gsub!(/MINOR = \d+/, "MINOR = 0")
        version_file.gsub!(/PATCH = \d+/, "PATCH = 0")
      when "minor"
        version_file.gsub!(/PATCH = \d+/, "PATCH = 0")
      end

      version_file.gsub!(/#{part.upcase} = \d+/, "#{part.upcase} = #{new_value}")

      # Write the new version
      File.write("lib/pylon/version.rb", version_file)

      # Update CHANGELOG.md
      changelog = File.read("CHANGELOG.md")
      new_version = Pylon::VERSION.sub(/\d+$/, new_value.to_s)

      changelog_entry = <<~ENTRY
        ## [#{new_version}] - #{Date.today.strftime('%Y-%m-%d')}

        ### #{part == 'patch' ? 'Fixed' : 'Added'}
        - TODO: Add #{part} version changes

        [#{new_version}]: https://github.com/benjodo/pylon-api/compare/v#{Pylon::VERSION}...v#{new_version}

      ENTRY

      # Split the changelog into parts
      header, *rest = changelog.split(/^## \[\d/)

      # Reconstruct the changelog with the new entry
      updated_changelog = [
        header,
        changelog_entry,
        rest.empty? ? "" : "## [#{rest.join('## [')}"
      ].join

      File.write("CHANGELOG.md", updated_changelog)

      puts "Bumped #{part} version to #{new_version}"
      puts "Don't forget to:"
      puts "1. Update CHANGELOG.md with your changes"
      puts "2. Commit the changes"
      puts "3. Create and push a new tag: git tag -a v#{new_version} -m 'Version #{new_version}'"
    end
  end

  desc "Add a pre-release identifier (e.g., alpha, beta, rc)"
  task :pre, [:identifier] do |_t, args|
    abort "Please provide a pre-release identifier (e.g., alpha, beta, rc)" unless args[:identifier]

    version_file = File.read("lib/pylon/version.rb")
    version_file.gsub!(/PRE = .*$/, "PRE = '#{args[:identifier]}'")

    File.write("lib/pylon/version.rb", version_file)

    require_relative "../pylon/version"
    puts "Updated version to #{Pylon::VERSION}"
  end

  desc "Remove pre-release identifier"
  task :release do
    version_file = File.read("lib/pylon/version.rb")
    version_file.gsub!(/PRE = .*$/, "PRE = nil")

    File.write("lib/pylon/version.rb", version_file)

    require_relative "../pylon/version"
    puts "Updated version to #{Pylon::VERSION}"
  end
end
