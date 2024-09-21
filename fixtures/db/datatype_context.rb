# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative "client_context"

module DB
	DatatypeContext = Sus::Shared("datatype context") do |adapter, datatype|
		include_context DB::ClientContext, adapter
		
		let(:table_name) {"datatype_test_#{datatype}".to_sym}
		
		before do
			Sync do
				client.session do |session|
					type = session.connection.types[datatype]
					
					session.query("DROP TABLE IF EXISTS %{table_name}", table_name: table_name).call
					session.query("CREATE TABLE %{table_name} (value #{type.name})", table_name: table_name).call
				end
			end
		end
	end
end
