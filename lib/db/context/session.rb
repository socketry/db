# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "../query"
require_relative "../records"

module DB
	# Provides context for database operations including sessions and transactions.
	module Context
		# A connected context for sending queries and reading results.
		class Session
			# Initialize the query context attached to the given connection pool.
			def initialize(pool, **options)
				@pool = pool
				@connection = nil
			end
			
			attr :pool
			attr :connection
			
			# Pin a connection to the current session.
			def connect!
				@connection ||= @pool.acquire
			end
			
			# Flush the connection and then return it to the connection pool.
			def close
				if @connection
					@pool.release(@connection)
					@connection = nil
				end
			end
			
			# Check if the session connection is closed.
			# @returns [Boolean] True if the connection is closed (nil), false otherwise.
			def closed?
				@connection.nil?
			end
			
			# Execute a block with a database connection, acquiring one if necessary.
			# @yields {|connection| ...} The connection block.
			# 	@parameter connection [Object] The database connection object.
			def with_connection(&block)
				if @connection
					yield @connection
				else
					@pool.acquire do |connection|
						@connection = connection
						
						yield connection
					ensure
						@connection = nil
					end
				end
			end
			
			# Send a query to the server.
			# @parameter statement [String] The SQL query to send.
			def call(statement, **options)
				self.with_connection do |connection|
					connection.send_query(statement, **options)
					
					if block_given?
						yield connection
					elsif result = connection.next_result
						return Records.wrap(result)
					end
				end
			end
			
			# Create a new query builder with optional initial fragment and parameters.
			# @parameter fragment [String] Initial SQL fragment for the query.
			# @parameter parameters [Hash] Parameters for interpolation into the fragment.
			# @returns [Query] A new query builder instance.
			def query(fragment = String.new, **parameters)
				with_connection do
					if parameters.empty?
						Query.new(self, fragment)
					else
						Query.new(self).interpolate(fragment, **parameters)
					end
				end
			end
			
			# Create a new query builder with an initial clause fragment.
			# @parameter fragment [String] Initial SQL clause fragment.
			# @returns [Query] A new query builder instance.
			def clause(fragment = String.new)
				with_connection do
					Query.new(self, fragment)
				end
			end
		end
	end
end
