#############################################################
###
##  File: wcml_helpers.rb
##  Desc: some methods to help work with *.wcml files
##        using the 'nokogiri' gem
#

module WcmlHelpers

  # open a file_pathname
  # read its contents into a Nokogiri structure
  def open_wcml(a_filepath)
    Nokogiri::XML(a_filepath.read)
  end


  # extract the story components from the structure
  def get_stories(a_wcml_doc)
    # NOTE: the wcml file has duplicate stories.  Don't know why.  The ones with
    #       a Link element have no content.  ASSuMEing it has something to do with
    #       the placement of the WCML file into a layout.
    a_wcml_doc.xpath("//Story").select {|a_story| a_story.xpath('.//Link').empty?}
  end


  # extract the story title from the story's attributes
  def get_story_title(a_story)
    a_story.attributes['StoryTitle'].value.split('/').last
  end


  # extract the plain text from the story
  def get_text(a_story)
    a_story.xpath('.//Content').to_s.
      gsub('</Content>',"\n").
      gsub('<Content>','').
      gsub('<Content/>','').
      chomp.strip
  end

end # module WcmlHelpers
