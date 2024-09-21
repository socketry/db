# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require 'db/client_context'

describe DB::Client do
	DB::Adapters.each do |name, klass|
		describe klass, unique: name do
			include_context DB::ClientContext, klass.new(**CREDENTIALS)
			
			it "can select version" do
				client.session do |session|
					result = session.call("SELECT VERSION()")
					expect(result).to be_a(DB::Records)
					
					row = result.rows.first
					expect(row[0]).to be_a(String)
				end
			end
			
			it "can execute multiple queries" do
				client.session do |session|
					query = <<~SQL * 2
						SELECT 42 AS LIFE;
					SQL
					
					session.call(query) do |connection|
						2.times do
							result = connection.next_result
							expect(result.to_a).to be == [[42]]
						end
					end
				end
			end
			
			it "can generate a query with literal values" do
				client.session do |session|
					session.clause("SELECT").literal(42).clause("AS").identifier(:LIFE).call do |connection|
						result = connection.next_result
						expect(result.to_a).to be == [[42]]
					end
				end
			end
			
			it "can generate a query using interpolations" do
				client.session do |session|
					session.query("SELECT %{value} AS %{column}", value: 42, column: :LIFE).call do |connection|
						result = connection.next_result
						expect(result.to_a).to be == [[42]]
					end
				end
			end
			
			it "can execute a query in a transaction" do
				client.transaction do |transaction|
					transaction.call("SELECT 42 AS LIFE") do |connection|
						result = connection.next_result
						expect(result.to_a).to be == [[42]]
					end
				end
			end
			
			with 'events table' do
				before do
					client.transaction do |transaction|
						transaction.call("DROP TABLE IF EXISTS events")
						
						transaction.call("CREATE TABLE IF NOT EXISTS events (#{transaction.connection.key_column}, created_at TIMESTAMP NOT NULL, description TEXT NULL)")
					end
				end
				
				it 'can insert rows with timestamps' do
					client.session do |session|
						session.call("INSERT INTO events (created_at, description) VALUES ('2020-05-04 03:02:01', 'Hello World')")
						
						rows = session.call('SELECT * FROM events') do |connection|
							connection.next_result.to_a
						end
						
						expect(rows).to be == [[1, Time.parse("2020-05-04 03:02:01 UTC"), "Hello World"]]
					end
				end
				
				it 'can insert null fields' do
					client.session do |session|
						session.call("INSERT INTO events (created_at, description) VALUES ('2020-05-04 03:02:01', NULL)")
						
						rows = session.call('SELECT * FROM events') do |connection|
							connection.next_result.to_a
						end
						
						expect(rows).to be == [[1, Time.parse("2020-05-04 03:02:01 UTC"), nil]]
					end
				end
			end
		end
	end
end
