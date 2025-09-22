# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "session"

module DB
	module Context
		# A database transaction context that extends Session with transaction management capabilities.
		class Transaction < Session
			# Begin a transaction.
			def begin
				self.connect!
				self.call("BEGIN")
			end
			
			# Commit the transaction and return the connection to the connection pool.
			def commit
				self.call("COMMIT")
				self.close
			end
			
			# Commit the transaction if it's still open, otherwise do nothing.
			# This is a safe version of commit that checks if the transaction is still active.
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
