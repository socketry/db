# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require 'covered/sus'
include Covered::Sus

Bundler.require(:adapters)

::CREDENTIALS = {
	username: 'test',
	password: 'test',
	database: 'test',
	host: '127.0.0.1'
}

# Used for PG.connect:
::PG_CREDENTIALS = CREDENTIALS.dup.tap do |credentials|
	credentials[:user] = credentials.delete(:username)
	credentials[:dbname] = credentials.delete(:database)
end
