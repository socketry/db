# Getting Started

This guide explains how to use `db` for database queries.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add db
~~~

## Core Concepts

`db` has several core concepts:

- A {ruby DB::Client} instance which is configured to connect to a specific database using an adapter, and manages a connection pool.
- A {ruby DB::Context::Session} instance which is bound to a specific connection and allows you to execute queries and enumerate results.

## Connecting to Postgres

Add the Postgres adaptor to your project:

~~~ bash
$ bundle add db-postgres
~~~

Set up the client with the appropriate credentials:

~~~ ruby
require 'async'
require 'db/client'
require 'db/postgres'

# Create the client and connection pool:
client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))

# Create an event loop:
Sync do
	# Connect to the database:
	session = client.session
	
	# Execute the query and get a result set:
	result = session.call("SELECT VERSION()")
	
	# Convert the result set to an array and print it out:
	pp result.to_a
	# => [["PostgreSQL 16.3 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 14.1.1 20240522, 64-bit"]]
ensure
	# Return the connection to the client connection pool:
	session.close
end
~~~

## Connection to MariaDB/MySQL

Add the MariaDB adaptor to your project:

~~~ bash
$ bundle add db-mariadb
~~~

Set up the client with the appropriate credentials:

~~~ ruby
require 'async'
require 'db/client'
require 'db/mariadb'

# Create the client and connection pool:
client = DB::Client.new(DB::MariaDB::Adapter.new(database: 'test'))

# Create an event loop:
Sync do
	# Connect to the database:
	session = client.session
	
	# Execute the query and get a result set:
	result = session.call("SELECT VERSION()")
	
	# Convert the result set to an array and print it out:
	pp result.to_a
	# => [["10.4.13-MariaDB"]]
ensure
	# Return the connection to the client connection pool:
	session.close
end
~~~
