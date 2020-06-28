
module DB
	module Adapters
		@adapters = {}
		
		def self.register(name, adapter)
			@adapters[name] = adapter
		end
		
		def self.each(&block)
			@adapters.each(&block)
		end
	end
end
