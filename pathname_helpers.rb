################################################
###
##  File: pathname_helpers.rb
##  Desc: Common methods used with pathnames
#

class Pathname

  def backup_path
    self.parent + "Backup of #{self.basename}"
  end

  def backup(the_backup_path=nil)
    the_backup_path = self.backup_path if the_backup_path.nil?
    FileUtils.copy_file(self, the_backup_path)
  end

end # class Pathname

