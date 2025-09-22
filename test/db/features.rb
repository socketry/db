# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "db/features"

describe DB::Features do
	with "default features" do
		let(:features) {DB::Features.new}
		
		it "should default all features to false" do
			expect(features).not.to be(:alter_column_type?)
			expect(features).not.to be(:modify_column?)
			expect(features).not.to be(:using_clause?)
			expect(features).not.to be(:conditional_operations?)
			expect(features).not.to be(:transactional_schema?)
			expect(features).not.to be(:batch_alter_table?)
			expect(features).not.to be(:concurrent_schema?)
			expect(features).not.to be(:deferred_constraints?)
			expect(features).not.to be(:serial_columns?)
			expect(features).not.to be(:auto_increment?)
			expect(features).not.to be(:integer_primary_key_autoincrement?)
			expect(features).not.to be(:identity_columns?)
		end
		
		it "should return false for unknown features via enabled?" do
			expect(features.enabled?(:unknown_feature)).to be == false
		end
		
		it "should return empty array for enabled_features" do
			expect(features.enabled_features).to be == []
		end
	end
	
	with "configured features" do
		let(:features) do
			DB::Features.new(
				alter_column_type: true,
				using_clause: true,
				conditional_operations: true,
				serial_columns: true
			)
		end
		
		it "should enable specified features" do
			expect(features).to be(:alter_column_type?)
			expect(features).to be(:using_clause?)
			expect(features).to be(:conditional_operations?)
			expect(features).to be(:serial_columns?)
		end
		
		it "should keep unspecified features disabled" do
			expect(features).not.to be(:modify_column?)
			expect(features).not.to be(:auto_increment?)
			expect(features).not.to be(:transactional_schema?)
		end
		
		it "should return true for enabled features via enabled?" do
			expect(features.enabled?(:alter_column_type)).to be == true
			expect(features.enabled?(:using_clause)).to be == true
			expect(features.enabled?(:conditional_operations)).to be == true
			expect(features.enabled?(:serial_columns)).to be == true
		end
		
		it "should return false for disabled features via enabled?" do
			expect(features.enabled?(:modify_column)).to be == false
			expect(features.enabled?(:auto_increment)).to be == false
		end
		
		it "should return enabled features list" do
			enabled = features.enabled_features
			expect(enabled).to be(:include?, :alter_column_type)
			expect(enabled).to be(:include?, :using_clause)
			expect(enabled).to be(:include?, :conditional_operations)
			expect(enabled).to be(:include?, :serial_columns)
			expect(enabled.length).to be == 4
		end
	end
	
	with "PostgreSQL-style features" do
		let(:features) do
			DB::Features.new(
				alter_column_type: true,
				using_clause: true,
				conditional_operations: true,
				transactional_schema: true,
				batch_alter_table: true,
				concurrent_schema: true,
				serial_columns: true,
				identity_columns: true
			)
		end
		
		it "should enable PostgreSQL features" do
			expect(features).to be(:alter_column_type?)
			expect(features).to be(:using_clause?)
			expect(features).to be(:transactional_schema?)
			expect(features).to be(:serial_columns?)
			expect(features).to be(:concurrent_schema?)
		end
		
		it "should not enable MySQL-specific features" do
			expect(features).not.to be(:modify_column?)
			expect(features).not.to be(:auto_increment?)
		end
	end
	
	with "MySQL-style features" do
		let(:features) do
			DB::Features.new(
				modify_column: true,
				conditional_operations: true,
				batch_alter_table: true,
				auto_increment: true
			)
		end
		
		it "should enable MySQL features" do
			expect(features).to be(:modify_column?)
			expect(features).to be(:auto_increment?)
			expect(features).to be(:conditional_operations?)
			expect(features).to be(:batch_alter_table?)
		end
		
		it "should not enable PostgreSQL-specific features" do
			expect(features).not.to be(:alter_column_type?)
			expect(features).not.to be(:using_clause?)
			expect(features).not.to be(:serial_columns?)
			expect(features).not.to be(:concurrent_schema?)
		end
	end
	
	with "SQLite-style features" do
		let(:features) do
			DB::Features.new(
				conditional_operations: true,
				integer_primary_key_autoincrement: true
			)
		end
		
		it "should enable SQLite features" do
			expect(features).to be(:conditional_operations?)
			expect(features).to be(:integer_primary_key_autoincrement?)
		end
		
		it "should not enable features SQLite doesn't support" do
			expect(features).not.to be(:alter_column_type?)
			expect(features).not.to be(:modify_column?)
			expect(features).not.to be(:transactional_schema?)
			expect(features).not.to be(:batch_alter_table?)
			expect(features).not.to be(:concurrent_schema?)
		end
	end
	
	with "#with method" do
		let(:base_features) do
			DB::Features.new(
				alter_column_type: true,
				using_clause: true
			)
		end
		
		it "should create new instance with additional features" do
			extended_features = base_features.with(modify_column: true, auto_increment: true)
			
			# Original features should be preserved:
			expect(extended_features).to be(:alter_column_type?)
			expect(extended_features).to be(:using_clause?)
			
			# New features should be added:
			expect(extended_features).to be(:modify_column?)
			expect(extended_features).to be(:auto_increment?)
			
			# Unspecified features should remain false:
			expect(extended_features).not.to be(:serial_columns?)
		end
		
		it "should override existing features" do
			modified_features = base_features.with(alter_column_type: false, serial_columns: true)
			
			# Original feature should be overridden:
			expect(modified_features).not.to be(:alter_column_type?)
			
			# Other original features should be preserved:
			expect(modified_features).to be(:using_clause?)
			
			# New feature should be added:
			expect(modified_features).to be(:serial_columns?)
		end
		
		it "should not modify the original instance" do
			original_alter_column = base_features.alter_column_type?
			original_using_clause = base_features.using_clause?
			
			# Create modified instance:
			base_features.with(modify_column: true, alter_column_type: false)
			
			# Original should be unchanged:
			expect(base_features.alter_column_type?).to be == original_alter_column
			expect(base_features.using_clause?).to be == original_using_clause
			expect(base_features).not.to be(:modify_column?)
		end
	end
end
