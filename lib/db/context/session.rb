# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative '../query'
require_relative '../records'

module DB
	module Context
		# A connected context for sending queries and reading results.
		class Session
			# Initialize the query context attached to the given connection pool.
			def initialize(pool, **options)
				@pool = pool
				@connection = nil
			end
			
			def connection?
				@connection != nil
			end
			
			# Lazy initialize underlying connection.
			def connection
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
			
			def query(fragment = String.new, **parameters)
				if parameters.empty?
					Query.new(self, fragment)
				else
					Query.new(self).interpolate(fragment, **parameters)
				end
			end
			
			def clause(fragment = String.new)
				Query.new(self, fragment)
			end
			
			# Send a query to the server.
			# @parameter statement [String] The SQL query to send.
			def call(statement, **options)
				connection = self.connection
				
				connection.send_query(statement, **options)
				
				if block_given?
					yield connection
				elsif result = connection.next_result
					return Records.wrap(result)
				end
			end
		end
	end
end
