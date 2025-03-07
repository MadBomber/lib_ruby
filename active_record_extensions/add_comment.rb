# lib/ruby/aactive+record_extensions/add_comment.rb
# Extensions to ActiveRecord::Migration

module MigrationExtensions
  # Adds a comment to a database schema
  # @param object_type (String or Symbol) [table|column]
  # @param name (String)  The name of the table; if its a column follows
  #                       this pattern: <table_name>.<column_name>
  # @param comment (String) The comment to add to the schema

  def add_comment(object_type, name, comment)
    object_type = object_type.to_s.upcase
    if object_type == "TABLE" || object_type == "COLUMN"
      execute "COMMENT ON #{object_type} #{name} IS '#{quote_string(comment)}';"
    else
      raise ArgumentError, "Unsupported object type: #{object_type}. Use 'table' or 'column'."
    end
  end

  private

  def quote_string(string)
    string.gsub("'", "''") # Escape single quotes for PostgreSQL
  end
end

# Include the extension in ActiveRecord::Migration
ActiveRecord::Migration.include(MigrationExtensions)
