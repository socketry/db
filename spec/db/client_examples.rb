# frozen_string_literal: true

# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

RSpec.shared_examples_for DB::Client do |adapter|
	subject{DB::Client.new(adapter)}
	
	it "can execute a query" do
		Sync do
			query = subject.call(<<~SQL * 2)
				SELECT 42 AS LIFE;
			SQL
			
			query.results do |result|
				result.each do |row|
					expect(row).to be == [42]
				end
			end
		end
	end
	
	it "can execute a query in a transaction" do
		Sync do
			transaction = subject.transaction
			
			result = transaction.call(<<~SQL)
				SELECT 42 AS LIFE;
			SQL
			
			expect(result.to_a).to be == [[42]]
			
			transaction.commit
		end
	end
	
	context 'with events table' do
		before do
			Sync do
				transaction = subject.transaction
				
				transaction.call("DROP TABLE IF EXISTS events")
				
				transaction.call("CREATE TABLE IF NOT EXISTS events (#{transaction.connection.id_column}, created_at TIMESTAMP NOT NULL, description TEXT NULL)")
				
				transaction.commit
			end
		end
		
		it 'can insert rows with timestamps' do
			Sync do
				subject.call("INSERT INTO events (created_at, description) VALUES ('2020-05-04 03:02:01', 'Hello World')").close
				
				query = subject.call('SELECT * FROM events')
				
				rows = nil
				
				query.results do |result|
					rows = result.to_a
				end
				
				expect(rows).to be == [[1, Time.parse("2020-05-04 03:02:01 UTC"), "Hello World"]]
			end
		end
		
		it 'can insert null fields' do
			Sync do
				subject.call("INSERT INTO events (created_at, description) VALUES ('2020-05-04 03:02:01', NULL)").close
				
				query = subject.call('SELECT * FROM events')
				
				rows = nil
				
				query.results do |result|
					rows = result.to_a
				end
				
				expect(rows).to be == [[1, Time.parse("2020-05-04 03:02:01 UTC"), nil]]
			end
		end
	end
end
