# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "benchmark/ips"
require "async"

require "db/client"
require "db/adapters"

require "mysql2"
require "pg"

describe DB::Client do
	it "should be fast to insert data" do
		Benchmark.ips do |x|
			DB::Adapters.each do |name, klass|
				adapter = klass.new(**CREDENTIALS)
				client = DB::Client.new(adapter)
				
				Sync do
					client.session do |session|
						session.call("DROP TABLE IF EXISTS benchmark")
						session.call("CREATE TABLE benchmark (#{session.connection.key_column}, i INTEGER)")
					end
				end
				
				x.report("db-#{name}") do |repeats|
					Sync do
						client.session do |session|
							session.call("TRUNCATE benchmark")
							
							repeats.times do |index|
								session.call("INSERT INTO benchmark (i) VALUES (#{index})")
							end
						end
					end
				end
			end
			
			x.report("mysql2") do |repeats|
				client = Mysql2::Client.new(**CREDENTIALS)
				client.query("TRUNCATE benchmark")
				
				repeats.times do |index|
					client.query("INSERT INTO benchmark (i) VALUES (#{index})")
				end
			end
			
			x.report("pg") do |repeats|
				client = PG.connect(**PG_CREDENTIALS)
				
				client.exec("TRUNCATE benchmark")
				
				repeats.times do |index|
					client.exec("INSERT INTO benchmark (i) VALUES (#{index})")
				end
			end
			
			x.compare!
		end
	end
	
	it "should be fast to select data" do
		row_count = 100
		insert_query = +"INSERT INTO benchmark (i) VALUES"
		
		row_count.times.map do |index|
			insert_query <<  " (#{index}),"
		end
		
		# Remove last comma:
		insert_query.chop!
		
		Benchmark.ips do |x|
			DB::Adapters.each do |name, klass|
				adapter = klass.new(**CREDENTIALS)
				client = DB::Client.new(adapter)
				
				Sync do
					client.session do |session|
						session.call("DROP TABLE IF EXISTS benchmark")
						session.call("CREATE TABLE benchmark (#{session.connection.key_column}, i INTEGER)")
						
						session.call(insert_query)
					end
				end
				
				x.report("db-#{name}") do |repeats|
					Sync do
						client.session do |session|
							repeats.times do |index|
								session.call("SELECT * FROM benchmark") do |connection|
									result = connection.next_result
									expect(result.to_a).to have_attributes(size: row_count)
								end
							end
						end
					end
				end
			end
			
			x.report("mysql2") do |repeats|
				client = Mysql2::Client.new(**CREDENTIALS)
				
				repeats.times do |index|
					result = client.query("SELECT * FROM benchmark")
					expect(result.to_a).to have_attributes(size: row_count)
				end
			end
			
			x.report("pg") do |repeats|
				client = PG.connect(**PG_CREDENTIALS)
				
				repeats.times do |index|
					result = client.exec("SELECT * FROM benchmark")
					expect(result.to_a).to have_attributes(size: row_count)
				end
			end
			
			x.compare!
		end
	end
end
