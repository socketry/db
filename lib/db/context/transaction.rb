# frozen_string_literal: true

# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyright, 2018, by Huba Nagy.
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

require_relative 'generic'

module DB
	module Context
		class Transaction < Generic
			def initialize(pool, statement)
				super(pool)
				
				@finished = false
				
				@connection.call(statement)
			end
			
			def commit
				@connection.call("COMMIT")
				self.close
			end
			
			def abort
				@connection.call("ROLLBACK")
				self.close
			end
			
			def savepoint(name)
				@connection.call("SAVEPOINT #{name}")
			end
			
			def rollback(name)
				@connection.call("ROLLBACK #{name}")
			end
			
			def close
				self.flush
				
				super
			end
			
			def call(statement, **options)
				@connection.send_query(statement, **options)
			end
			
			def results
				while result = self.next_result
					yield result
				end
			end
			
			def next_result
				unless @finished
					result = @connection.next_result
					
					if result
						return result
					else
						return nil
					end
				end
			end
			
			def flush
				until @finished
					@finished ||= @connection.next_result.nil?
				end
			end
		end
	end
end 
