

class Todo < Sequel::Model
	set_primary_key [ :id ]
	set_schema do
		serial :id
		text :summary
		timestamp :created_at
	end
end

Todo.create_table unless Todo.table_exists?