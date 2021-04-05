# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative '../query'

module DB
	module Context
		# A connected context for sending queries and reading results.
		class Generic
			# Iniitalize the query context attached to the given connection pool.
			def initialize(pool, **options)
				@pool = pool
				@connection = nil
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
			
			def clause(fragment = String.new)
				Query.new(self, fragment)
			end
			
			def query(fragment = String.new, **parameters)
				if parameters.empty?
					Query.new(self, fragment)
				else
					Query.new(self).interpolate(fragment, **parameters)
				end
			end
			
			# Send a query to the server.
			# @parameter statement [String] The SQL query to send.
			def call(statement, **options)
				connection.send_query(statement, **options)
				
				yield connection if block_given?
			ensure
				self.close
			end
		end
	end
end
