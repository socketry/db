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

require_relative 'session'

module DB
	module Context
		class Transaction < Session
			# Commit the transaction and return the connection to the connection pool.
			def commit
				self.call("COMMIT")
				self.close
			end
			
			def commit?
				unless self.closed?
					self.commit
				end
			end
			
			# Abort the transaction and return the connection to the connection pool.
			def abort
				self.call("ROLLBACK")
				self.close
			end
			
			# Mark a savepoint in the transaction.
			def savepoint(name)
				self.call("SAVEPOINT #{name}")
			end
			
			# Return back to a previously registered savepoint.
			def rollback(name)
				self.call("ROLLBACK #{name}")
			end
		end
	end
end 
