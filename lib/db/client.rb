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

require 'async/io'
require 'async/io/stream'
require 'async/pool/controller'

module DB
	class Client
		def initialize(adapter, **options)
			@adapter = adapter
			
			@pool = connect(**options)
		end
		
		attr :endpoint
		attr :protocol
		
		# @return [client] if no block provided.
		# @yield [client, task] yield the client in an async task.
		def self.open(*arguments, &block)
			client = self.new(*arguments)
			
			return client unless block_given?
			
			Async do |task|
				begin
					yield client, task
				ensure
					client.close
				end
			end.wait
		end
		
		def close
			@pool.close
		end
		
		def call(*statement, **options, &block)
			@pool.acquire do |connection|
				connection.query(*statement, **options, &block)
			end
		end
		
		protected
		
		def connect(**options)
			Async::Pool::Controller.new(@adapter, **options)
		end
	end
end
