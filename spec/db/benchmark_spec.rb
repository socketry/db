# frozen_string_literal: true

# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'benchmark/ips'
require 'async'

require 'db/client'
require 'db/adapters'

require 'mysql2'
require 'pg'

RSpec.describe DB::Client do
	it "should be fast to insert data" do
		Benchmark.ips do |x|
			DB::Adapters.each do |name, klass|
				adapter = klass.new(database: 'test')
				client = DB::Client.new(adapter)
				
				Sync do
					session = client.call
					
					session.call("DROP TABLE IF EXISTS benchmark")
					session.call("CREATE TABLE benchmark (#{session.connection.id_column}, i INTEGER)")
				end
				
				x.report("db-#{name}") do |repeats|
					Sync do
						session = client.call
						session.call('TRUNCATE benchmark')
						
						repeats.times do |index|
							session.call("INSERT INTO benchmark (i) VALUES (#{index})")
						end
					end
				end
			end
			
			x.report('mysql2') do |repeats|
				client = Mysql2::Client.new(database: 'test')
				client.query('TRUNCATE benchmark')
				
				repeats.times do |index|
					client.query("INSERT INTO benchmark (i) VALUES (#{index})")
				end
			end
			
			x.report('pg') do |repeats|
				client = PG.connect(dbname: 'test')
				client.exec('TRUNCATE benchmark')
				
				repeats.times do |index|
					client.exec("INSERT INTO benchmark (i) VALUES (#{index})")
				end
			end
			
			x.compare!
		end
	end
end
