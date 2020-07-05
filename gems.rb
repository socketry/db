source "https://rubygems.org"

# Specify your gem's dependencies in db.gemspec
gemspec

group :adapters do
	gem "db-postgres"#, path: "../db-postgres"
	gem "db-mariadb"#, path: "../db-mariadb"
end
