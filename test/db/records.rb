# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "db/records"

describe DB::Records do
	describe ".wrap" do
		it "returns nil when field_count is 0" do
			mock_result = Object.new
			def mock_result.field_count
				0
			end
			
			result = DB::Records.wrap(mock_result)
			expect(result).to be_nil
		end
		
		it "creates a Records instance when field_count > 0" do
			mock_result = Object.new
			def mock_result.field_count
				2
			end
			
			def mock_result.field_names
				["id", "name"]
			end
			
			def mock_result.to_a
				[[1, "Alice"], [2, "Bob"]]
			end
			
			result = DB::Records.wrap(mock_result)
			expect(result).to be_a(DB::Records)
			expect(result.columns).to be == ["id", "name"]
			expect(result.rows).to be == [[1, "Alice"], [2, "Bob"]]
		end
	end
	
	describe "#initialize" do
		it "sets columns and rows" do
			columns = ["id", "name"]
			rows = [[1, "Alice"], [2, "Bob"]]
			
			records = DB::Records.new(columns, rows)
			
			expect(records.columns).to be == columns
			expect(records.rows).to be == rows
		end
	end
	
	describe "#freeze" do
		it "freezes the instance and its data" do
			columns = ["id", "name"]
			rows = [[1, "Alice"], [2, "Bob"]]
			
			records = DB::Records.new(columns, rows)
			result = records.freeze
			
			expect(result).to be == records
			expect(records.frozen?).to be == true
			expect(records.columns.frozen?).to be == true
			expect(records.rows.frozen?).to be == true
		end
		
		it "returns self if already frozen" do
			columns = ["id", "name"].freeze
			rows = [[1, "Alice"], [2, "Bob"]].freeze
			
			records = DB::Records.new(columns, rows)
			records.freeze
			
			# Call freeze again
			result = records.freeze
			expect(result).to be == records
		end
	end
	
	describe "#to_a" do
		it "returns the rows array" do
			columns = ["id", "name"]
			rows = [[1, "Alice"], [2, "Bob"]]
			
			records = DB::Records.new(columns, rows)
			
			expect(records.to_a).to be == rows
			expect(records.to_a).to be_equal(rows)
		end
	end
end