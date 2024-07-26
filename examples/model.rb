# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module LoginSchema
	include DB::Schema
	
	class User
		property :name
		property :password, BCrypt
	end
	
	has_many :users, User
	
	def call(username, password)
		if user = users.find(username: username)
			return user.password == password
		end
	end
end

module TodoSchema
	include DB::Schema
	
	class Item
		property :description
		property :due, Optional[DateTime]
		
		belongs_to :user, LoginSchema::User
	end
	
	has_many :items, Item
end

module AppliationSchema
	include DB::Schema
	
	schema :login => LoginSchema
	schema :todo => TodoSchema
end

client = DB::Client.new(DB::Postgres::Adapter.new(database: 'test'))
schema = ApplicationSchema.new(client)

schema.login.call(username, password)

pp schema.todo.todos # => [TodoSchema::Todo, ...]
