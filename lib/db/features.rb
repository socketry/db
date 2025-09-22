# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module DB
	# Standardized feature detection for database adapters.
	# All features default to false, and adapters can enable specific capabilities.
	class Features
		def initialize(**features)
			@features = features
		end
		
		# Check if a specific feature is enabled.
		def enabled?(feature)
			@features.fetch(feature, false)
		end
		
		# Get all enabled features.
		def enabled_features
			@features.select{|_, enabled| enabled}.keys
		end
		
		# Create a new Features instance with additional or modified features.
		def with(**additional_features)
			self.class.new(**@features, **additional_features)
		end
		
		# PostgreSQL-style column type modification: ALTER COLUMN name TYPE type USING expression.
		def alter_column_type?
			@features.fetch(:alter_column_type, false)
		end
		
		# MySQL-style column modification: MODIFY COLUMN name type.
		def modify_column?
			@features.fetch(:modify_column, false)
		end
		
		# Support for USING clause in column type changes.
		def using_clause?
			@features.fetch(:using_clause, false)
		end
		
		# Support for IF EXISTS/IF NOT EXISTS clauses.
		def conditional_operations?
			@features.fetch(:conditional_operations, false)
		end
		
		# Schema operations can be rolled back within transactions.
		def transactional_schema?
			@features.fetch(:transactional_schema, false)
		end
		
		# Multiple operations can be combined in a single ALTER TABLE statement.
		def batch_alter_table?
			@features.fetch(:batch_alter_table, false)
		end
		
		# Support for concurrent/online schema changes.
		def concurrent_schema?
			@features.fetch(:concurrent_schema, false)
		end
		
		# Support for adding constraints with validation deferred.
		def deferred_constraints?
			@features.fetch(:deferred_constraints, false)
		end
		
		# PostgreSQL-style SERIAL/BIGSERIAL auto-increment columns.
		def serial_columns?
			@features.fetch(:serial_columns, false)
		end
		
		# MySQL-style AUTO_INCREMENT auto-increment columns.
		def auto_increment?
			@features.fetch(:auto_increment, false)
		end
		
		# SQLite-style INTEGER PRIMARY KEY auto-increment.
		def integer_primary_key_autoincrement?
			@features.fetch(:integer_primary_key_autoincrement, false)
		end
		
		# Support for IDENTITY columns (SQL Server/newer PostgreSQL).
		def identity_columns?
			@features.fetch(:identity_columns, false)
		end
	end
end
