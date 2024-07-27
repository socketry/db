# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'db/datatype_context'

DatetimeDatatype = Sus::Shared("datetime datatype") do |adapter|
	include_context DB::DatatypeContext, adapter, :datetime
	
	it "can insert utc time" do
		time = Time.utc(2020, 07, 02, 10, 11, 12)
		session = client.session
		
		session.query("INSERT INTO %{table_name} (value) VALUES (%{value})", table_name: table_name, value: time).call
		
		row = session.query("SELECT * FROM %{table_name}", table_name: table_name).call.to_a.first
		
		expect(row.first).to be == time
	end
	
	it "can insert local time" do
		time = Time.new(2020, 07, 02, 10, 11, 12, "+12:00")
		session = client.session
		
		session.query("INSERT INTO %{table_name} (value) VALUES (%{value})", table_name: table_name, value: time).call
		
		row = session.query("SELECT * FROM %{table_name}", table_name: table_name).call.to_a.first
		
		expect(row.first).to be == time
	end
end

DB::Adapters.each do |name, klass|
	describe klass, unique: klass do
		it_behaves_like DatetimeDatatype, klass.new(**CREDENTIALS)
	end
end
