
require 'ffi/postgres'
require 'async/pool/resource'

module DB
	module Postgres
		LOCAL = "postgres://localhost/postgres"
		
		class Adapter
			def initialize(connection_string = LOCAL)
				@connection_string = connection_string
			end
			
			attr :connection_string
			
			def call
				Connection.new(self.connection_string)
			end
		end
		
		module IO
			def self.new(fd, mode)
				Async::IO::Generic.new(::IO.new(fd, mode))
			end
		end
		
		class Connection < Async::Pool::Resource
			def initialize(connection_string)
				@wrapper = FFI::Postgres::Connection.connect(
					connection_string, io: IO
				)
				
				super()
			end
			
			def query(string, &block)
				@wrapper.query(string, &block)
			end
		end
	end
end
