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
- A {ruby DB::Context::Query} instance which is bound to a specific connection and allows you to execute queries and enumerate results.

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

client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))

Sync do
	session = client.call
	
	result = session.call("SHOW SERVER_VERSION")
	
	pp result.to_a
	# => [["12.3"]]
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

client = DB::Client.new(DB::MariaDB::Adapter.new(database: 'test'))

Sync do
	session = client.call
	
	result = session.call("SELECT VERSION()")
	
	pp result.to_a
	# => [["10.4.13-MariaDB"]]
end
~~~
