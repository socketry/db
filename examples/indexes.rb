#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "async"
require_relative "../lib/db/client"
require "db/postgres"

# Create the client and connection pool:
client = DB::Client.new(DB::Postgres::Adapter.new(database: "test"))

def create_schema(session)
	session.clause("DROP TABLE IF EXISTS").identifier(:things).call
	
	session.clause("CREATE TABLE IF NOT EXISTS")
		.identifier(:things)
		.clause("(")
			# .identifier(:id).clause("BIGSERIAL PRIMARY KEY,")
			.identifier(:low).clause("INT NOT NULL,")
			.identifier(:high).clause("INT NOT NULL")
		.clause(")").call
	
	session.clause("SET default_statistics_target=10000;").call
	session.clause("CREATE STATISTICS low_high_statistics (dependencies) ON low, high FROM things;").call
end

# Depending on the structure of the index, the query can be handled in different ways.
# A bottom heavy index has few nodes at the root, so that in theory, cutting a node at the root reduces the search space by the biggest amount possible.
#
#        low     high
# Top -> 1    -> 1 million children
#     -> 2    -> 1 milllion children
#
# Query in `low` is O(2) then produces a subsequent O(1 million) lookup.
#
# A top heavy index has as many possible nodes at the root, so that a single lookup produces the smallest set of possible options.
#
#        low             high
# Top -> 1 million    -> 2 children
#     -> ...          -> 2 children
#
# Query in `low` is O(1 million) then produces a subsequent O(2) lookup.
#
# Different internal index structure may yield different results.
#
# In the general case above, we have structured the data so that they are essentially equivlent, e.g. O(low) followed by O(high) or O(high) followed by O(low). However, data does not often follow this structure. Often you will have unbalanced trees. Our query performance will be determined by the tree structure and whether we can avoid comparisons by culling potential search space as early as possible.
def create_data(session)
	million = (0...1_000_000).to_a
	
	rows = {
		5  => million.dup,
		10 => million.dup,
		15 => million.dup,
		20 => million.dup,
		25 => million.dup,
		30 => million.dup,
		35 => million.dup,
		40 => million.dup,
		45 => million.dup,
		50 => million.dup,
	}
	
	rows.each do |low, values|
		insert = session.clause("INSERT INTO").identifier(:things)
			.clause("(")
				.identifier(:low).clause(",")
				.identifier(:high)
			.clause(")")
			.clause("VALUES")
		
		while high = values.pop
			insert.clause("(")
				.literal(low).clause(",")
				.literal(high)
			
			if values.empty?
				insert.clause(")")
			else
				insert.clause("),")
			end
		end
		
		insert.call
	end
end

def create_index(session, low_high: true, high_low: true)
	session.clause("SET default_statistics_target=10000;").call
	
	if low_high
		session.clause("CREATE INDEX IF NOT EXISTS")
			.identifier(:low_high)
			.clause("ON").identifier(:things).clause("(")
				.identifier(:low).clause(",")
				.identifier(:high)
			.clause(")").call
	else
		session.clause("DROP INDEX IF EXISTS").identifier(:low_high)
	end
	
	if high_low
		session.clause("CREATE INDEX IF NOT EXISTS")
			.identifier(:high_low)
			.clause("ON").identifier(:things).clause("(")
				.identifier(:high).clause(",")
				.identifier(:low)
			.clause(")").call
	else
		session.clause("DROP INDEX IF EXISTS").identifier(:high_low)
	end
end

permutations = [
	# {low_high: false, high_low: false},
	{low_high: true, high_low: false},
	{low_high: false, high_low: true},
	{low_high: true, high_low: true},
]

# Create an event loop:
Sync do
	# Connect to the database:
	session = client.session
	
	create_schema(session)
	create_data(session)
	
	permutations.each do |permutation|
		Console.logger.info(session, permutation)
		
		create_index(session, **permutation)
		
		# Warm up the table/index:
		(1..3).each do |i|
			result = session.query("SELECT low, high FROM things WHERE low = #{i} AND high = 5001").call.to_a
		end
		
		analysis = session.query("EXPLAIN ANALYZE SELECT low, high FROM things WHERE low = 25 AND high = 500000").call.to_a
		Console.logger.info(session, *analysis.flatten)
		
		Console.logger.measure("query") do
			10_000.times do |i|
				result = session.query("SELECT low, high FROM things WHERE low = #{i % 50} AND high = #{(i * 12351237) % 1_000_000}").call.to_a
				# pp result
			end
		end
	end
end
