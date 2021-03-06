#####################################################################
###
##  File:  hash_mods.rb
##  Desc:  Modifications to the Array class.
#

class Hash

  # from http://cookieshq.co.uk/posts/find-values-key-nested-hash-ruby/
  def find_all_values_for(key)

    result = [self[key]]

    self.values.each do |hash_value|

      values = [hash_value] unless hash_value.is_a? Array

      values.each do |value|
        result += value.find_all_values_for(key) if value.is_a? Hash
      end

    end

    result.compact

  end

end # class Hash
