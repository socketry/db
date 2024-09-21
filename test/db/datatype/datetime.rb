# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "db/datatype_context"

describe "datetime datatype" do
	DB::Adapters.each do |name, klass|
		describe klass, unique: name do
			include_context DB::DatatypeContext, klass.new(**CREDENTIALS), :datetime
			
			it "can insert utc time" do
				time = Time.utc(2020, 07, 02, 10, 11, 12)
				client.session do |session|
					session.query("INSERT INTO %{table_name} (value) VALUES (%{value})", table_name: table_name, value: time).call
					
					row = session.query("SELECT * FROM %{table_name}", table_name: table_name).call.to_a.first
					
					expect(row.first).to be == time
				end
			end
			
			it "can insert local time" do
				time = Time.new(2020, 07, 02, 10, 11, 12, "+12:00")
				
				client.session do |session|
					session.query("INSERT INTO %{table_name} (value) VALUES (%{value})", table_name: table_name, value: time).call
					
					row = session.query("SELECT * FROM %{table_name}", table_name: table_name).call.to_a.first
					
					expect(row.first).to be == time
				end
			end
		end
	end
end
