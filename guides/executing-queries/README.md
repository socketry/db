# Executing Queries

This guide explains how to escape and execute queries. In order to execute a query, you need a connection. Database connections are stateful, and this state is encapsulated by a context.

## Contexts

Contexts represent a stateful connection to a remote server. The most generic kind, {ruby DB::Context::Session} provides methods for sending queries and processing results. {ruby DB::Context::Transaction} extends this implementation and adds methods for database transactions.

### Sessions

A {ruby DB::Context::Session} represents a connection to the database server and can be used to send queries to the server and read rows of results.

~~~ ruby
require 'async'
require 'db/client'
require 'db/postgres'

client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))

Sync do
	session = client.session
	
	# Build a query, injecting the literal 42 and the identifier LIFE into the statement:
	result = session
		.clause("SELECT").literal(42)
		.clause("AS").identifier(:LIFE).call
	
	pp result.to_a
	# => [[42]]
end
~~~

### Transactions

Transactions ensure consistency when selecting and inserting data. While the exact semantics are server specific, transactions normally ensure that all statements execute at a consistent point in time and that if any problem occurs during the transaction, the entire transaction is aborted.

~~~ ruby
require 'async'
require 'db/client'
require 'db/postgres'

client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))

Sync do
	session = client.transaction
	
	# Use the explicit DSL for generating queries:
	session.clause("CREATE TABLE")
		.identifier(:users)
		.clause("(")
			.identifier(:id).clause("BIGSERIAL PRIMARY KEY,")
			.identifier(:name).clause("VARCHAR NOT NULL")
		.clause(")").call
	
	# Use interpolation for generating queries:
	session.query(<<~SQL, table: :users, column: :name, value: "ioquatix").call
		INSERT INTO %{table} (%{column}) VALUES (%{value})
	SQL
	
	result = session.clause("SELECT * FROM").identifier(:users).call
	
	pp result.to_a
	
	session.abort
	
ensure
	session.close
end
~~~

Because the session was aborted, the table and data are never committed:

~~~ ruby
require 'async'
require 'db/client'
require 'db/postgres'

client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))

Sync do
	session = client.session
	
	result = session.clause("SELECT * FROM").identifier(:users).call
	# => DB::Postgres::Error: Could not get next result: ERROR:  relation "users" does not exist
	
	pp result.to_a
	
ensure
	session.close
end
~~~

### Closing Sessions

It is important that you close a session or commit/abort a transaction (implicit close). Closing a session returns it to the connection pool. If you don't do this, you will leak connections. Both {ruby DB::Client#session} and {ruby DB::Client#transaction} can accept blocks and will implicitly close/commit/abort as appropriate.

## Query Builder

A {ruby DB::Query} builder is provided to help construct queries and avoid SQL injection attacks. This query builder is bound to a {ruby DB::Context::Session} instance and provides convenient methods for constructing a query efficiently.

### Low Level Methods

There are several low level methods for constructing queries.

- {ruby DB::Query#clause} appends an unescaped fragment of SQL text.
- {ruby DB::Query#literal} appends an escaped literal value (e.g. {ruby String}, {ruby Integer}, {ruby true}, {ruby nil}, etc).
- {ruby DB::Query#identifier} appends an escaped identifier ({ruby Symbol}, {ruby Array}, {ruby DB::Identifier}).

~~~ ruby
require 'async'
require 'db/client'
require 'db/postgres'

client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))

Sync do
	session = client.session
	
	# Build a query, injecting the literal 42 and the identifier LIFE into the statement:
	result = session
		.clause("SELECT").literal(42)
		.clause("AS").identifier(:LIFE)
		.call
	
	pp result.to_a
	# => [[42]]
end
~~~

### Interpolation Method

You can also use string interpolation to safely construct queries.

- {ruby DB::Query#interpolate} appends an interpolated query string with escaped parameters.

~~~ ruby
require 'async'
require 'db/client'
require 'db/postgres'

client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))

Sync do
	session = client.session
	
	# Build a query, injecting the literal 42 and the identifier LIFE into the statement:
	result = session.query(<<~SQL, value: 42, column: :LIFE).call
		SELECT %{value} AS %{column}
	SQL
	
	pp result.to_a
	# => [[42]]
end
~~~

Named parameters are escaped and substituted into the given fragment.
