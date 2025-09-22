# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "db/query"

describe DB::Identifier do
	it "can coerce from another identifier" do
		original = DB::Identifier.new([:table, :column])
		result = DB::Identifier.coerce(original)
		
		expect(result).to be == original
	end
	
	it "can coerce from an array" do
		result = DB::Identifier.coerce([:table, :column])
		
		expect(result).to be_a(DB::Identifier)
		expect(result).to be == [:table, :column]
	end
	
	it "can coerce from a symbol" do
		result = DB::Identifier.coerce(:column)
		
		expect(result).to be_a(DB::Identifier)
		expect(result).to be == [:column]
	end
	
	it "can coerce from a string" do
		result = DB::Identifier.coerce("column")
		
		expect(result).to be_a(DB::Identifier)
		expect(result).to be == [:column]
	end
	
	it "can append to a query" do
		identifier = DB::Identifier.new([:table, :column])
		mock_query = Object.new
		
		# Mock the identifier method
		def mock_query.identifier(value)
			@identifier_value = value
		end
		
		def mock_query.identifier_value
			@identifier_value
		end
		
		identifier.append_to(mock_query)
		
		expect(mock_query.identifier_value).to be == identifier
	end
end