# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

module DB
	# Represents one or more identifiers for databases, tables or columns.
	class Identifier < Array
		# Convert various input types to an Identifier instance.
		# @parameter name_or_identifier [Identifier, Array, Symbol, String] The value to convert.
		# @returns [Identifier] An Identifier instance.
		def self.coerce(name_or_identifier)
			case name_or_identifier
			when Identifier
				name_or_identifier
			when Array
				self.new(name_or_identifier)
			when Symbol
				self[name_or_identifier]
			else
				self[name_or_identifier.to_sym]
			end
		end
		
		# Append this identifier to the provided query builder.
		# @parameter query [Query] The query builder to append to.
		def append_to(query)
			query.identifier(self)
		end
	end
	
	# A mutable query builder.
	class Query
		# Create a new query builder attached to the specified context.
		# @parameter context [Context::Generic] the context which is used for escaping arguments.
		def initialize(context, buffer = String.new)
			@context = context
			@connection = context.connection
			@buffer = +buffer
		end
		
		# Append a raw textual clause to the query buffer.
		# @parameter value [String] A raw SQL string, e.g. `WHERE x > 10`.
		# @returns [Query] The mutable query itself.
		def clause(value)
			@buffer << " " unless @buffer.end_with?(" ") || @buffer.empty?
			
			@buffer << value
			
			return self
		end
		
		# Append a literal value to the query buffer.
		# Escapes the field according to the requirements of the underlying connection.
		# @parameter value [Object] Any kind of object, passed to the underlying database connection for conversion to a string representation.
		# @returns [Query] The mutable query itself.
		def literal(value)
			@buffer << " " unless @buffer.end_with?(" ")
			
			@connection.append_literal(value, @buffer)
			
			return self
		end
		
		# Append an identifier value to the query buffer.
		# Escapes the field according to the requirements of the underlying connection.
		# @parameter value [String | Symbol | DB::Identifier] Passed to the underlying database connection for conversion to a string representation.
		# @returns [Query] The mutable query itself.
		def identifier(value)
			@buffer << " " unless @buffer.end_with?(" ")
			
			@connection.append_identifier(value, @buffer)
			
			return self
		end
		
		# Interpolate a query fragment with the specified parameters.
		# The parameters are escaped before being appended.
		#
		# @parameter fragment [String] A fragment of SQL including placeholders, e.g. `WHERE x > %{column}`.
		# @parameter parameters [Hash] The substitution parameters.
		# @returns [Query] The mutable query itself.
		def interpolate(fragment, **parameters)
			parameters.transform_values! do |value|
				case value
				when Symbol, Identifier
					@connection.append_identifier(value)
				else
					@connection.append_literal(value)
				end
			end
			
			@buffer << sprintf(fragment, parameters)
			
			return self
		end
		
		# Generate a key column expression based on the connection's requirements.
		# @parameter arguments [Array] Arguments passed to the connection's key_column method.
		# @parameter options [Hash] Options passed to the connection's key_column method.
		# @returns [Query] The mutable query itself.
		def key_column(*arguments, **options)
			@buffer << @connection.key_column(*arguments, **options)
			
			return self
		end
		
		# Send the query to the remote server to be executed. See {Context::Session#call} for more details.
		# @returns [Enumerable] The resulting records.
		def call(&block)
			# Console.debug(self, "Executing query...", buffer: @buffer)
			@context.call(@buffer, &block)
		end
		
		# Get the string representation of the query buffer.
		# @returns [String] The accumulated query string.
		def to_s
			@buffer
		end
		
		# Inspect the query instance showing the class and current buffer contents.
		# @returns [String] A string representation for debugging.
		def inspect
			"\#<#{self.class} #{@buffer.inspect}>"
		end
	end
end
