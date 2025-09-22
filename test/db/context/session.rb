# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "db/context/session"

describe DB::Context::Session do
	let(:mock_pool) do
		pool = Object.new
		
		def pool.acquire(&block)
			@connection ||= Object.new
			
			if block_given?
				yield @connection
			else
				@connection
			end
		end
		
		def pool.release(connection)
			# Mock release
		end
		
		pool
	end
	
	let(:session) {DB::Context::Session.new(mock_pool)}
	
	describe "#closed?" do
		it "returns true when connection is nil" do
			expect(session.closed?).to be == true
		end
		
		it "returns false when connection is present" do
			session.connect!
			expect(session.closed?).to be == false
		end
	end
	
	describe "#with_connection" do
		it "yields existing connection when available" do
			session.connect!
			connection = session.connection
			
			yielded_connection = nil
			session.with_connection do |conn|
				yielded_connection = conn
			end
			
			expect(yielded_connection).to be == connection
		end
		
		it "acquires and releases connection when none exists" do
			yielded_connection = nil
			session.with_connection do |conn|
				yielded_connection = conn
			end
			
			expect(yielded_connection).not.to be_nil
			expect(session.closed?).to be == true
		end
	end
	
	describe "#query" do
		let(:mock_connection) do
			connection = Object.new
			
			def connection.append_literal(value, buffer = String.new)
				buffer << "'#{value}'"
				buffer
			end
			
			def connection.append_identifier(value, buffer = String.new)
				buffer << "`#{value}`"
				buffer
			end
			
			connection
		end
		
		before do
			session.connect!
			# Replace the connection with our mock
			session.instance_variable_set(:@connection, mock_connection)
		end
		
		it "creates a query with empty fragment by default" do
			query = session.query
			expect(query).to be_a(DB::Query)
			expect(query.to_s).to be == ""
		end
		
		it "creates a query with initial fragment" do
			query = session.query("SELECT * FROM users")
			expect(query).to be_a(DB::Query)
			expect(query.to_s).to be(:include?, "SELECT * FROM users")
		end
		
		it "creates a query with interpolated parameters" do
			query = session.query("SELECT %{column} FROM %{table}", column: :name, table: :users)
			expect(query).to be_a(DB::Query)
			expect(query.to_s).to be(:include?, "`name`")
			expect(query.to_s).to be(:include?, "`users`")
		end
	end
	
	describe "#clause" do
		before do
			session.connect!
		end
		
		it "creates a query with empty fragment by default" do
			query = session.clause
			expect(query).to be_a(DB::Query)
			expect(query.to_s).to be == ""
		end
		
		it "creates a query with initial clause fragment" do
			query = session.clause("WHERE id = 1")
			expect(query).to be_a(DB::Query)
			expect(query.to_s).to be(:include?, "WHERE id = 1")
		end
	end
end