# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "db/context/transaction"

describe DB::Context::Transaction do
	let(:mock_pool) do
		pool = Object.new
		
		def pool.acquire
			@connection ||= Object.new
		end
		
		def pool.release(connection)
			# Mock release
		end
		
		pool
	end
	
	let(:mock_connection) do
		connection = Object.new
		
		def connection.send_query(statement, **options)
			@queries ||= []
			@queries << statement
		end
		
		def connection.next_result
			# Mock result for transaction queries
			nil
		end
		
		def connection.queries
			@queries || []
		end
		
		connection
	end
	
	let(:transaction) {DB::Context::Transaction.new(mock_pool)}
	
	describe "#commit?" do
		it "commits when transaction is open" do
			# Mock the transaction to have a connection
			transaction.instance_variable_set(:@connection, mock_connection)
			
			result = transaction.commit?
			
			expect(transaction.closed?).to be == true
			expect(mock_connection.queries).to be(:include?, "COMMIT")
		end
		
		it "does nothing when transaction is already closed" do
			# Ensure transaction is closed
			expect(transaction.closed?).to be == true
			
			# commit? should do nothing
			transaction.commit?
			
			expect(transaction.closed?).to be == true
		end
	end
	
	describe "#abort" do
		it "rolls back and closes the transaction" do
			transaction.instance_variable_set(:@connection, mock_connection)
			
			transaction.abort
			
			expect(transaction.closed?).to be == true
			expect(mock_connection.queries).to be(:include?, "ROLLBACK")
		end
	end
	
	describe "#savepoint" do
		it "creates a named savepoint" do
			transaction.instance_variable_set(:@connection, mock_connection)
			
			transaction.savepoint("test_savepoint")
			
			expect(mock_connection.queries).to be(:include?, "SAVEPOINT test_savepoint")
		end
	end
	
	describe "#rollback" do
		it "rolls back to a named savepoint" do
			transaction.instance_variable_set(:@connection, mock_connection)
			
			transaction.rollback("test_savepoint")
			
			expect(mock_connection.queries).to be(:include?, "ROLLBACK test_savepoint")
		end
	end
end