# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative 'session'

module DB
	module Context
		# A connected context for sending queries and reading results.
		class Transient < Session
			def call(statement, **options, &block)
				super
			ensure
				self.close
			end
		end
	end
end
