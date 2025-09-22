# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

source "https://rubygems.org"

# Specify your gem's dependencies in db.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	gem "bake-releases"
	
	gem "agent-context"
	
	gem "utopia-project"
end

group :adapters do
	gem "db-postgres"
	gem "db-mariadb"
end

group :benchmark do
	gem "benchmark-ips", "~> 2.8.0"
	gem "mysql2"
	gem "pg"
end

group :test do
	gem "sus"
	gem "covered"
	gem "decode"
	
	gem "rubocop"
	gem "rubocop-md"
	gem "rubocop-socketry"
	
	gem "sus-fixtures-async"
	
	gem "bake-test"
	gem "bake-test-external"
end
