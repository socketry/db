# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	# A buffer of records.
	class Records
		# Wrap a database result into a Records instance.
		# @parameter result [Object] The database result object with field_count, field_names, and to_a methods.
		# @returns [Records, Nil] A Records instance or nil if there are no columns.
		def self.wrap(result)
			# We want to avoid extra memory allocations when there are no columns:
			if result.field_count == 0
				return nil
			end
			
			return self.new(result.field_names, result.to_a)
		end
		
		# Initialize a new Records instance with columns and rows.
		# @parameter columns [Array] Array of column names.
		# @parameter rows [Array] Array of row data.
		def initialize(columns, rows)
			@columns = columns
			@rows = rows
		end
		
		# Freeze the Records instance and its internal data structures.
		# @returns [Records] The frozen Records instance.
		def freeze
			return self if frozen?
			
			@columns.freeze
			@rows.freeze
			
			super
		end
		
		attr :columns
		attr :rows
		
		# Get the rows as an array.
		# @returns [Array] The array of row data.
		def to_a
			@rows
		end
	end
end
