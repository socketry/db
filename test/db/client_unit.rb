# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "db/client"

describe DB::Client do
	let(:mock_adapter) do
		adapter = Object.new
		adapter
	end
	
	let(:mock_pool) do
		pool = Object.new
		
		def pool.close
			@closed = true
		end
		
		def pool.wait_until_free
			yield if block_given?
		end
		
		def pool.closed?
			@closed == true
		end
		
		pool
	end
	
	let(:client) do
		client = DB::Client.new(mock_adapter)
		# Replace the pool with our mock
		client.instance_variable_set(:@pool, mock_pool)
		client
	end
	
	describe "#close" do
		it "waits for pool to drain and closes it" do
			client.close
			
			expect(mock_pool.closed?).to be == true
		end
	end
end