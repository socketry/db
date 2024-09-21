# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "db"

describe DB do
	it "has a version number" do
		expect(DB::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
end
