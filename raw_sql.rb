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

  class SyntaxError   < RuntimeError; end
  class KeyError      < RuntimeError; end
  class QueryError    < RuntimeError; end
  class FileNotFound  < RuntimeError; end

  include ActiveRecord::ConnectionAdapters::Quoting

  class << self

    def timestamp
      Time.now.strftime("%Y-%m-%d %H:%M:%S.%3N")
    end


    def warning(a_string='You have been warned')
      STDERR.puts "#{timestamp} RawSQL::WARNING #{a_string}"
    end


    def error(a_string='Stop the errors.')
      STDERR.puts "#{timestamp} RawSQL::ERROR   #{a_string}"
    end


    def query(sql_filename, parameters={})
      sql_statement = do_parameter_substitution(
            get_text_file_contents(sql_filename),
            parameters
          )

      begin
        return ActiveRecord::Base.connection.execute(sql_statement)
      rescue Exception => e
        raise QueryError
      end
    end


    def do_parameter_substitution(a_string, parameters={})

      a_string.gsub!('${', '%{') # NOTE: Javashit uses ${} for string templates
      a_string.gsub!('#{', '%{') # NOTE: Rubists are use to using #{} in strings

      required_keys = a_string.scan( /%{([^}]*)}/).flatten.uniq.sort
      provided_keys = parameters.keys.map{|k| k.to_s}.sort

      missing_keys  = required_keys - provided_keys
      unused_keys   = provided_keys - required_keys

      unless unused_keys.empty?
        warning "Unused template keys: #{unused_keys.join(', ')}"
      end

      unless missing_keys.empty?
        error "Missing template keys: #{missing_keys.join(', ')}"
        raise KeyError
      end

      return (parameters.empty? ? a_string : a_string % parameters)
    end # def do_parameter_substitution(a_string, parameters)


    def get_text_file_contents(filename)
      begin
        a_file = File.open(filename, 'r')
      rescue Exception => e
        error e
        raise FileNotFound if e.to_s.start_with? 'No such file'
        raise e
      end
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
