# version_model.rb

class VersionModel
  include Comparable

  def initialize str_or_int_or_class
    case str_or_int_or_class
      when Integer
        @version_i  = str_or_int_or_class
        @tag        = ''
      when String
        if str_or_int_or_class.include?('-')
          tmp                 = str_or_int_or_class.split('-')
          @tag                = tmp.last
          str_or_int_or_class = tmp.first
        end
        @version_i  = self.class.from_string(str_or_int_or_class.to_s).to_i
      when VersionModel
        @version_i  = str_or_int_or_class.to_i
        @tag        = str_or_int_or_class.tag
      else
        raise ArgumentError, "Must be of class String, Integer or VersionModel; not #{str_or_int_or_class.class}"
    end # case str_or_int_or_class.class
  end # def initialize str_or_int_or_class

  def major
    @version_i >> 24
  end

  def minor
    (@version_i & 0xFF0000) >> 16
  end

  def revision
    (@version_i & 0xFF00) >> 8
  end

  def patch
    @version_i & 0xFF
  end

  def tag
    @tag
  end

  def base
    a_string = "#{major}"
    a_string +=".#{minor}"      unless 0==minor && 0==revision && 0==patch
    a_string +=".#{revision}"   unless 0==revision && 0==patch
    a_string +=".#{patch}"      unless 0==patch
    return a_string
  end

  def to_i
    @version_i
  end

  def to_s
    (@tag.nil? || @tag.empty?) ? base : "#{base}-#{tag}"
  end

  def inspect
    "VersionModel(#{self.to_s})"
  end

  # NOTE: ignores the tag
  def <=> other
    case other
      when String
        @version_i <=> VersionModel.new(other).to_i
      when Integer
        @version_i <=> other
      when VersionModel
        @version_i <=> other.to_i
      else
        raise ArgumentError, "Comparision must be to a String, Integer or VersionModel class; not #{other.class}"
    end
  end

  class << self
    def from_string a_string
      # non-integer elements are treated as 0
      temp = a_string.split('.').map{|e| e.to_i}
      5.times{ temp << 0} # initialize extra version levels to zero

      major, minor, revision, patch = temp
      
      major, minor, revision, patch = Integer(major), Integer(minor), Integer(revision), Integer(patch)

      if major >= 256 || minor >= 256 || revision >= 256 || patch >= 256
        raise ArgumentError, "VersionModel elements must be less than 256" 
      end

      VersionModel.new (major << 24) | (minor << 16) | (revision << 8) | patch
    end

    def is_valid? a_string
      !!from_string(a_string) rescue false
    end
  end # class << self
end # class VersionModel
