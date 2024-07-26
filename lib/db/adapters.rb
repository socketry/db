# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

module DB
	# A global map of registered adapters.
	# e.g. `DB::Adapters.register(:mariadb, DB::MariaDB::Adapter)`
	module Adapters
		@adapters = {}
		
		# Register the adapter class to the specified name.
		# @parameter name [Symbol] The adapter name.
		# @parameter adapter [Class] The adapter class.
		def self.register(name, adapter)
			@adapters[name] = adapter
		end
		
		# Enumerate all registered adapters.
		# @yields {|name, adapter| ...} The adapters if a block is given.
		# 	@parameter name [Symbol] The adapter name.
		# 	@parameter adapter [Class] The adapter class
		# @returns [Enumerator(Symbol, Class)] If no block is given.
		def self.each(&block)
			@adapters.each(&block)
		end
	end
end
