# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require 'async/pool/controller'

require_relative 'context/transient'
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
			context = Context::Transient.new(@pool, **options)
			
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
