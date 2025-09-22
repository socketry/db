# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "db/query"

describe DB::Query do
	let(:mock_connection) do
		connection = Object.new
		
		def connection.key_column(*args, **options)
			"id BIGSERIAL PRIMARY KEY"
		end
		
		connection
	end
	
	let(:mock_context) do
		context = Object.new
		
		def context.connection
			@connection
		end
		
		def context.connection=(connection)
			@connection = connection
		end
		
		context.connection = mock_connection
		context
	end
	
	let(:query) {DB::Query.new(mock_context)}
	
	it "can append key_column" do
		result = query.key_column
		
		expect(result).to be == query
		expect(query.to_s).to be(:include?, "id BIGSERIAL PRIMARY KEY")
	end
	
	it "can convert to string" do
		query.clause("SELECT 1")
		
		expect(query.to_s).to be == "SELECT 1"
	end
	
	it "can be inspected" do
		query.clause("SELECT 1")
		
		result = query.inspect
		expect(result).to be(:include?, "DB::Query")
		expect(result).to be(:include?, "SELECT 1")
	end
	
	with "custom buffer" do
		let(:query) {DB::Query.new(mock_context, "INITIAL")}
		
		it "starts with the custom buffer" do
			expect(query.to_s).to be == "INITIAL"
		end
		
		it "includes custom buffer in inspect" do
			result = query.inspect
			expect(result).to be(:include?, "INITIAL")
		end
	end
end