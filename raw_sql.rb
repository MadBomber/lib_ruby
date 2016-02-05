# raw_sql.rb
#
# idea from http://gmile.me/raw-sql-in-a-rails-project
#
# Typilcal uses:
#
# result = RawSQL.query('path_to_file.sql')
#
# on a "result" object:
#   1. call .to_a to get an array of hashes,
#   2. call .fields to get a list of field names (aka columns)
#     fields = RawSQL.query('path_to_file.sql').fields
# 
# NOTE: this library ASSUMES that ActiveRecord is already loaded
#       and a database connection has been made
# 
#

class RawSQL
  
  include ActiveRecord::ConnectionAdapters::Quoting

  class << self

    def query(sql_filename, parameters={})
      return ActiveRecord::Base.connection.execute(
        do_parameter_substitution( 
          get_text_file_contents(sql_filename), 
          parameters 
        ) 
      )
    end

    def do_parameter_substitution(a_string, parameters)
      a_string.gsub!('${', '%{') # NOTE: Javashit uses ${} for string templates
      if a_string.include?('%{')    &&
         Hash == parameters.class   &&
         parameters.size > 0
        return( a_string % parameters )   
      end
      return(a_string)
    end

    def get_text_file_contents(filename)
      a_file = File.open(filename, 'r')
      a_string = a_file.read
      a_file.close
      return a_string
    end

    def quoted_parameters(parameters)
      parameters.each_with_object({}) do |(key, value), result|

        result[key] =
          if value.is_a?(Array)
            value.map { |item| quote(item) }.join(', ')
          elsif value.is_a?(Integer)
            value
          else
            quote(value)
          end

      end # parameters.each_with_object({}) do |(key, value), result|
    end # def quoted_parameters(parameters)

  end # class << self
end # class RawSQL
