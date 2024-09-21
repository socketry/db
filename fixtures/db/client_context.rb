# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "db/client"
require "db/adapters"
require "sus/fixtures/async"

module DB
	ClientContext = Sus::Shared("client context") do |adapter|
		include Sus::Fixtures::Async::ReactorContext
		
		let(:client) {DB::Client.new(adapter)}
	end
end
