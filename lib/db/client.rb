# frozen_string_literal: true

# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'async/io'
require 'async/io/stream'
require 'async/pool/controller'

require_relative 'context/generic'
require_relative 'context/session'
require_relative 'context/transaction'

module DB
	# Binds a connection pool to the specified adapter.
	class Client
		# Initialize the client and internal connection pool using the specified adapter.
		# @parameter adapter [Object] The adapter instance.
		def initialize(adapter, **options)
			@adapter = adapter
			
			@pool = connect(**options)
		end
		
		# The adapter used for making connections.
		# @attribute [Object]
		attr :adapter
		
		# Close all open connections in the connection pool.
		def close
			@pool.close
		end
		
		# Acquire a generic context which will acquire a connection on demand.
		def context(**options)
			context = Context::Generic.new(@pool, **options)
			
			return context unless block_given?
			
			begin
				yield context
			ensure
				context.close
			end
		end
		
		# Acquires a connection and sends the specified statement if given.
		# @parameters statement [String | Nil] An optional statement to send.
		# @yields {|session| ...} A connected session if a block is given. Implicitly closed.
		# 	@parameter session [Context::Session]
		# @returns [Context::Session] A connected session if no block is given.
		def session(**options)
			session = Context::Session.new(@pool, **options)
			
			return session unless block_given?
			
			begin
				yield session
			ensure
				session.close
			end
		end
		
		# Acquires a connection and starts a transaction.
		# @parameters statement [String | Nil] An optional statement to send. Defaults to `"BEGIN"`.
		# @yields {|session| ...} A connected session if a block is given. Implicitly commits, or aborts the connnection if an exception is raised.
		# 	@parameter session [Context::Transaction]
		# @returns [Context::Transaction] A connected and started transaction if no block is given.
		def transaction(**options)
			transaction = Context::Transaction.new(@pool, **options)
			
			transaction.call("BEGIN")
			
			return transaction unless block_given?
			
			begin
				yield transaction
				
			rescue
				transaction.abort
				raise
			ensure
				transaction.commit?
			end
		end
		
		protected
		
		def connect(**options)
			Async::Pool::Controller.new(@adapter, **options)
		end
	end
end
