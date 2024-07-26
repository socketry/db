# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require 'db/client'
require 'db/adapters'
require 'sus/fixtures/async'

AClient = Sus::Shared("a client") do |adapter|
	include Sus::Fixtures::Async::ReactorContext
	
	let(:client) {DB::Client.new(adapter)}
	
	it "can select version" do
		context = client.context
		
		result = context.call("SELECT VERSION()")
		expect(result).to be_a(DB::Records)
		
		row = result.rows.first
		expect(row[0]).to be_a(String)
	end
	
	it "can execute multiple queries" do
		context = client.context
		
		query = <<~SQL * 2
			SELECT 42 AS LIFE;
		SQL
		
		context.call(query) do |connection|
			2.times do
				result = connection.next_result
				expect(result.to_a).to be == [[42]]
			end
		end
	ensure
		context.close
	end
	
	it "can generate a query with literal values" do
		session = client.session
		
		session.clause("SELECT").literal(42).clause("AS").identifier(:LIFE).call do |connection|
			result = connection.next_result
			expect(result.to_a).to be == [[42]]
		end
	ensure
		session.close
	end
	
	it "can generate a query using interpolations" do
		session = client.session
		
		session.query("SELECT %{value} AS %{column}", value: 42, column: :LIFE).call do |connection|
			result = connection.next_result
			expect(result.to_a).to be == [[42]]
		end
	ensure
		session.close
	end
	
	it "can execute a query in a transaction" do
		transaction = client.transaction
		
		transaction.call("SELECT 42 AS LIFE") do |connection|
			result = connection.next_result
			expect(result.to_a).to be == [[42]]
		end
		
		transaction.commit
	ensure
		transaction.close
	end
	
	with 'events table' do
		def before
			super
			
			transaction = client.transaction
			
			transaction.call("DROP TABLE IF EXISTS events")
			
			transaction.call("CREATE TABLE IF NOT EXISTS events (#{transaction.connection.key_column}, created_at TIMESTAMP NOT NULL, description TEXT NULL)")
			
			transaction.commit
		ensure
			transaction.close
		end
		
		it 'can insert rows with timestamps' do
			session = client.session
			
			session.call("INSERT INTO events (created_at, description) VALUES ('2020-05-04 03:02:01', 'Hello World')")
			
			rows = session.call('SELECT * FROM events') do |connection|
				connection.next_result.to_a
			end
			
			expect(rows).to be == [[1, Time.parse("2020-05-04 03:02:01 UTC"), "Hello World"]]
		ensure
			session.close
		end
		
		it 'can insert null fields' do
			session = client.session
			
			session.call("INSERT INTO events (created_at, description) VALUES ('2020-05-04 03:02:01', NULL)")
			
			rows = session.call('SELECT * FROM events') do |connection|
				connection.next_result.to_a
			end
			
			expect(rows).to be == [[1, Time.parse("2020-05-04 03:02:01 UTC"), nil]]
		ensure
			session.close
		end
	end
end

DB::Adapters.each do |name, klass|
	describe klass do
		it_behaves_like AClient, klass.new(**CREDENTIALS)
	end
end
