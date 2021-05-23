source "https://rubygems.org"

# Specify your gem's dependencies in db.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-bundler"
	
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
