###########################################################
###
##  File:  mods_to_standard_classes.rb
##  Desc:  Over-rides or additions to standard ruby classes
#

# Added titleize method to Array to support the display of the
# defended area and launch area labels which could be multiple
# over-laping areas.
class Array
  def titleize
    self.uniq.join(', ').titleize
  end
end

