# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "db/adapters"

describe DB::Adapters do
	let(:test_adapter) {Class.new}
	
	it "can register an adapter" do
		DB::Adapters.register(:test_adapter, test_adapter)
		
		found_adapter = nil
		DB::Adapters.each do |name, adapter|
			if name == :test_adapter
				found_adapter = adapter
				break
			end
		end
		
		expect(found_adapter).to be == test_adapter
	end
	
	it "can enumerate registered adapters" do
		DB::Adapters.register(:test_adapter_1, test_adapter)
		DB::Adapters.register(:test_adapter_2, test_adapter)
		
		adapters = []
		DB::Adapters.each do |name, adapter|
			adapters << [name, adapter]
		end
		
		# Check that our test adapters are in the list
		adapter_names = adapters.map(&:first)
		expect(adapter_names).to be(:include?, :test_adapter_1)
		expect(adapter_names).to be(:include?, :test_adapter_2)
	end
	
	it "returns an enumerator when no block is given" do
		enumerator = DB::Adapters.each
		expect(enumerator).to be_a(Enumerator)
	end
end