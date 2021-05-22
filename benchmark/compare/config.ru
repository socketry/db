require 'active_record'
ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "test", pool: 64)

require_relative '../../lib/db'
require 'db/postgres'

# TracePoint.new(:fiber_switch) do |trace_point|
# 	$stderr.puts "************* fiber switch (pid=#{Process.pid}) *************"
# 	$stderr.puts caller.first(8).join("\n")
# 	$stderr.puts
# end.enable

class Compare
	def initialize(app)
		@app = app
		@db = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))
	end
	
	PATH_INFO = 'PATH_INFO'.freeze
	OK = [200, [], ["OK"]]
	
	def active_record_checkout(env)
		Console.logger.measure("active_record") do
			connection = ActiveRecord::Base.connection_pool.checkout
			connection.execute("SELECT pg_sleep(1)")
		ensure
			ActiveRecord::Base.connection_pool.checkin(connection)
		end
		
		OK
	end
	
	def active_record_with_connection(env)
		Console.logger.measure("active_record") do
			ActiveRecord::Base.connection_pool.with_connection do |connection|
				connection.execute("SELECT pg_sleep(1)")
			end
		end
		
		OK
	end
	
	def active_record(env)
		Console.logger.measure("active_record") do
			ActiveRecord::Base.connection.execute("SELECT pg_sleep(1)")
		end
		
		OK
	end
	
	def db(env)
		Console.logger.measure("db") do
			@db.session do |session|
				session.query("SELECT pg_sleep(1)").call
			end
		end
		
		OK
	end
	
	def call(env)
		_, name, *path = env[PATH_INFO].split("/")
		
		method = name&.to_sym
		
		if method and self.respond_to?(method)
			self.send(method, env)
		else
			@app.call(env)
		end
	end
end

use Compare

run lambda {|env| [404, {}, ["Not Found"]]}
