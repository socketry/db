# frozen_string_literal: true

# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module DB
	# Represents one or more identifiers for databases, tables or columns.
	class Identifier < Array
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
			@buffer << ' ' unless @buffer.end_with?(' ') || @buffer.empty?
			
			@buffer << value
			
			return self
		end
		
		# Append a literal value to the query buffer.
		# Escapes the field according to the requirements of the underlying connection.
		# @parameter value [Object] Any kind of object, passed to the underlying database connection for conversion to a string representation.
		# @returns [Query] The mutable query itself.
		def literal(value)
			@buffer << ' ' unless @buffer.end_with?(' ')
			
			@connection.append_literal(value, @buffer)
			
			return self
		end
		
		# Append an identifier value to the query buffer.
		# Escapes the field according to the requirements of the underlying connection.
		# @parameter value [String | Symbol | DB::Identifier] Passed to the underlying database connection for conversion to a string representation.
		# @returns [Query] The mutable query itself.
		def identifier(value)
			@buffer << ' ' unless @buffer.end_with?(' ')
			
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
		
		def key_column(*arguments, **options)
			@buffer << @connection.key_column(*arguments, **options)
			
			return self
		end
		
		# Send the query to the remote server to be executed. See {Context::Session#call} for more details.
		# @returns [Enumerable] The resulting records.
		def call(&block)
			if block_given?
				@context.call(@buffer, &block)
			else
				@context.call(@buffer) do |connection|
					return connection.next_result
				end
			end
		end
		
		def to_s
			@buffer
		end
		
		def inspect
			"\#<#{self.class} #{@buffer.inspect}>"
		end
	end
end
