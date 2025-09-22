# Example Queries

This guide shows a variety of example queries using the DB gem.

## Setup

~~~ ruby
require 'async'
require 'db/client'
require 'db/postgres'

client = DB::Client.new(DB::Postgres::Adapter.new(
	database: 'test',
	host:	    '172.17.0.3',
	password: 'test',
	username: 'postgres',
))
~~~

## A simple CREATE, INSERT and SELECT, with raw SQL

~~~ ruby
Sync do
	session = client.session

	create = "CREATE TABLE IF NOT EXISTS my_table (a_timestamp TIMESTAMP NOT NULL)"
	session.query(create).call

	insert = "INSERT INTO my_table VALUES (NOW()), ('2022-12-12 12:13:14')"
	session.query(insert).call

	result = session.query("SELECT * FROM my_table WHERE a_timestamp > NOW()").call

	Console.info result.field_types.to_s
	Console.info result.field_names.to_s
	Console.info result.to_a.to_s
ensure
	session&.close
end
~~~

### Output

~~~
 0.01s     info: [#<DB::Postgres::Native::Types::DateTime:0x00007eff3b13e688 @name="TIMESTAMP">]
 0.01s     info: ["a_timestamp"]
 0.01s     info: [[2022-12-12 12:13:14 UTC]]
~~~

## Parameterized CREATE, INSERT and SELECT

The same process as before, but parameterized. Always use the parameterized form when dealing with untrusted data.

~~~ ruby
Sync do
	session = client.session

	session.clause("CREATE TABLE IF NOT EXISTS")
		.identifier(:my_table)
		.clause("(")
			.identifier(:a_timestamp).clause("TIMESTAMP NOT NULL")
		.clause(")")
		.call

	session.clause("INSERT INTO")
		.identifier(:my_table)
		.clause("VALUES (")
			.literal("NOW()")
		.clause("), (")
			.literal("2022-12-12 12:13:14")
		.clause(")")
		.call

	result = session.clause("SELECT * FROM")
		.identifier(:my_table)
		.clause("WHERE")
		.identifier(:a_timestamp).clause(">").literal("NOW()")
		.call

	Console.info result.field_types.to_s
	Console.info result.field_names.to_s
	Console.info result.to_a.to_s
ensure
	session&.close
end
~~~

### Output

~~~
 0.01s     info: [#<DB::Postgres::Native::Types::DateTime:0x00007eff3b13e688 @name="TIMESTAMP">]
 0.01s     info: ["a_timestamp"]
 0.01s     info: [[2022-12-12 12:13:14 UTC]]
~~~

## A parameterized SELECT

~~~ ruby
Sync do |task|
	session = client.session
	result = session
		.clause("SELECT")
		.identifier(:column_one)
		.clause(",")
		.identifier(:column_two)
		.clause("FROM")
		.identifier(:another_table)
		.clause("WHERE")
		.identifier(:id)
		.clause("=")
		.literal(42)
		.call

	Console.info "#{result.field_names}"
	Console.info "#{result.to_a}"
end
~~~

### Output

~~~
 0.01s     info: ["column_one", "column_two"]
 0.01s     info: [["foo", "bar"], ["baz", "qux"]]
~~~

## Concurrent queries

(Simulating slow queries with `PG_SLEEP`)

~~~ ruby
Sync do |task|
	start = Time.now
	tasks = 10.times.map do
		task.async do
			session = client.session
			result = session.query("SELECT PG_SLEEP(10)").call
			result.to_a
		ensure
			session&.close
		end
	end

	results = tasks.map(&:wait)

	Console.info "Elapsed time: #{Time.now - start}s"
end
~~~

### Output

~~~
10.05s     info: Elapsed time: 10.049756222s
~~~

## Limited to 3 connections

(Simulating slow queries with `PG_SLEEP`)

~~~ ruby
require 'async/semaphore'

Sync do
	semaphore = Async::Semaphore.new(3)
	tasks = 10.times.map do |i|
		semaphore.async do
			session = client.session
			Console.info "Starting task #{i}"
			result = session.query("SELECT PG_SLEEP(10)").call
			result.to_a
		ensure
			session&.close
		end
	end

	results = tasks.map(&:wait)
	Console.info "Done"
end
~~~

### Output

~~~
  0.0s     info: Starting task 0
  0.0s     info: Starting task 1
  0.0s     info: Starting task 2
10.02s     info: Completed task 0 after 10.017388464s
10.02s     info: Starting task 3
10.02s     info: Completed task 1 after 10.02111175s
10.02s     info: Starting task 4
10.03s     info: Completed task 2 after 10.027889587s
10.03s     info: Starting task 5
20.03s     info: Completed task 3 after 10.011089096s
20.03s     info: Starting task 6
20.03s     info: Completed task 4 after 10.008169111s
20.03s     info: Starting task 7
20.04s     info: Completed task 5 after 10.007644749s
20.04s     info: Starting task 8
30.04s     info: Completed task 6 after 10.011244562s
30.04s     info: Starting task 9
30.04s     info: Completed task 7 after 10.011565997s
30.04s     info: Completed task 8 after 10.004611464s
40.05s     info: Completed task 9 after 10.008239803s
40.05s     info: Done
~~~

## Sequential vs Concurrent INSERTs

~~~ ruby
DATA = 1_000_000.times.map { SecureRandom.hex }

def setup_tables(client)
	session = client.session

	create = "CREATE TABLE IF NOT EXISTS salts (salt CHAR(32))"
	session.query(create).call

	truncate = "TRUNCATE TABLE salts"
	session.query(truncate).call

	session.close
end

def chunked_insert(rows, client, task=Async::Task.current)
	task.async do
		session = client.session
		rows.each_slice(1000) do |slice|
			insert = "INSERT INTO salts VALUES " + slice.map { |x| "('#{x}')" }.join(",")
			session.query(insert).call
		end
	ensure
		session&.close
	end
end

Sync do
	Console.info "Setting up tables"
	setup_tables(client)
	Console.info "Done"

	start = Time.now
	Console.info "Starting sequential insert"
	chunked_insert(DATA, client).wait
	Console.info "Completed sequential insert in #{Time.now - start}s"

	start = Time.now
	Console.info "Starting concurrent insert"
	DATA.each_slice(10_000).map do |slice|
		chunked_insert(slice, client)
	end.each(&:wait)
	Console.info "Completed concurrent insert in #{Time.now - start}s"
end
~~~

### Output

~~~
 1.45s     info: Setting up tables
 1.49s     info: Done
 1.49s     info: Starting sequential insert
 8.49s     info: Completed sequential insert in 7.006533933s
 8.49s     info: Starting concurrent insert
 9.92s     info: Completed concurrent insert in 1.431470847s
~~~
