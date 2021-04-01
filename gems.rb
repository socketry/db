source "https://rubygems.org"

# Specify your gem's dependencies in db.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-bundler"
	
	gem "utopia-project"
end

group :adapters do
	gem "db-postgres", "~> 0.4.0"
	gem "db-mariadb", "~> 0.7.0"
end

group :benchmark do
	gem "benchmark-ips"
	gem "mysql2"
	gem "pg"
end
