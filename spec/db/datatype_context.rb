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

RSpec.shared_context "datatype" do |adapter, data_type|
	subject{DB::Client.new(adapter)}
	let(:table_name) {:datatype_test}
	
	before do
		Sync do
			subject.session do |session|
				type = session.connection.types[data_type]
				
				session.query("DROP TABLE IF EXISTS %{table_name}", table_name: table_name).call
				session.query("CREATE TABLE %{table_name} (value #{type.name})", table_name: table_name).call
			end
		end
	end
end

RSpec.shared_context "database that supports Time" do |adapter|
	include_context "datatype", adapter, :datetime do
		it "can insert utc time" do
			Sync do
				time = Time.utc(2020, 07, 02, 10, 11, 12)
				session = subject.session
				
				session.query("INSERT INTO %{table_name} (value) VALUES (%{value})", table_name: table_name, value: time).call
				
				row = session.query("SELECT * FROM %{table_name}", table_name: table_name).call.to_a.first
				
				expect(row.first).to be == time
			end
		end
		
		it "can insert local time" do
			Sync do
				time = Time.new(2020, 07, 02, 10, 11, 12, "+12:00")
				session = subject.session
				
				session.query("INSERT INTO %{table_name} (value) VALUES (%{value})", table_name: table_name, value: time).call
				
				row = session.query("SELECT * FROM %{table_name}", table_name: table_name).call.to_a.first
				
				expect(row.first).to be == time
			end
		end
	end
end