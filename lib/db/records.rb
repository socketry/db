# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	# A buffer of records.
	class Records
		def self.wrap(result)
			# We want to avoid extra memory allocations when there are no columns:
			if result.field_count == 0
				return nil
			end
			
			return self.new(result.field_names, result.to_a)
		end
		
		def initialize(columns, rows)
			@columns = columns
			@rows = rows
		end
		
		def freeze
			return self if frozen?
			
			@columns.freeze
			@rows.freeze
			
			super
		end
		
		attr :columns
		attr :rows
		
		def to_a
			@rows
		end
	end
end
