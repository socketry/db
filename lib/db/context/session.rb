# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "../query"
require_relative "../records"

module DB
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
			
			def closed?
				@connection.nil?
			end
			
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
			
			def query(fragment = String.new, **parameters)
				with_connection do
					if parameters.empty?
						Query.new(self, fragment)
					else
						Query.new(self).interpolate(fragment, **parameters)
					end
				end
			end
			
			def clause(fragment = String.new)
				with_connection do
					Query.new(self, fragment)
				end
			end
		end
	end
end
