##############################################
###
##  File: refinements_file.rb
##  Desc: useful? refinements on the File class
#
#   This code for the most part came from the sugar_refinery gem.
#

module Refinements

  refine ::File do

    # Given an existing filename and a hash,
    # replace in the file each key in the hash
    # if that key's value.  The keys can be
    # Regex objects or any other object that responds_to? :to_s
    #
    # The values in the hash can be strings or Procs.
    #
    # TODO: Create `gsub` version with a to_filename parameter
    #
    def gsub!(filename, regex_hash, backup: false)
      data = File.read filename

      if backup
        bak_filename  = filename.to_s + '.bak'  # allow for a Pathname
        bak_file      = File.open(bak_filename, 'w')
        bak_file.print data
        bak_file.close
      end

      File.open(filename,'w') do |file|

        regex_hash.each do |regex, new_string|
          regex = regex.to_s unless regex.is_a? Regexp

          if new_string.is_a? Proc
            data.gsub! regex, &new_string
          else
            data.gsub! regex, new_string
          end
        end

        file.print data
      end
    end


    # copy the contents of one file into another replacing
    # the contents where the keys of the regex_hash object
    # match with the associated value from the regex_hash
    # object.
    #
    # to_filename is the name of the file to receive the
    # modified file contents.   If to_filename is omitted
    # the contents will be returned as a string.
    #
    def gsub(filename, regex_hash, to_filename: nil)
      raise 'NotImplemented'
    end
  end
end
