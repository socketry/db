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
				Console.logger.info(query) {"#{result.row_count} #{result.field_names}"}
				result.each do |row|
					Console.logger.info(result, row)
				end
			end
		end
	end
	
	it "can execute a query in a transaction" do
		Sync do
			transaction = subject.transaction
			
			transaction.call(<<~SQL)
				SELECT 42 AS LIFE;
			SQL
			
			transaction.results do |result|
				puts "**************** #{result.row_count} #{result.field_names}"
				result.each do |row|
					pp row
				end
			end
			
			transaction.commit
		end
	end
end