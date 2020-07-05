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

RSpec.describe DB::Client do
	it "should be fast to insert data" do
		Benchmark.ips do |x|
			DB::Adapters.each do |name, klass|
				x.report(name) do |repeats|
					Sync do
						client = klass.new(database: 'test')
						
						transaction = client.transaction
						
						transaction.call("DROP TABLE IF EXISTS benchmark")
						transaction.call("CREATE TABLE bencmark (#{transaction.connection.id_column}, index INTEGER)")
						
						transaction.commit
						
						repeats.times do |index|
							client.query("INSERT INTO benchmark (index) VALUES (#{index})")
						end
					end
				end
			end
			
			x.compare!
		end
	end
end
