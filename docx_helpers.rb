#############################################################
###
##  File: docx_helpers.rb
##  Desc: some methods to help work with *.docx files
##        using the 'docx' gem
#

module DocxHelpers

  def open_docx(a_filepath)
    Docx::Document.open(a_filepath)
  end

  def insert_new_paragraph(some_text, style, this_docx)
    new_para      = this_docx.paragraphs.last.copy
    new_para.text = strip_tags(some_text)
    set_paragraph_style_name(new_para, style)
    new_para.insert_after(this_docx.paragraphs.last)
  end

  def delete_paragraph(a_paragraph)
    a_paragraph.node.remove  # NOTE: invoke the nokogiri #remove on the node
  end

  def get_paragraph_style_name(a_paragraph)
    begin
      # SMELL: an xpath may be easier to maintain
      style_name = a_paragraph.node.children[0].children[0].attributes['val'].value
      # SMELL: sometimes the style name ends in digits to make it unique
      #        within the MS Word document.
      while ( ("0".."9").include?(style_name[style_name.length-1]) ) do
        style_name = style_name[0,style_name.length-1]
      end
      return style_name
    rescue
      "AbbyNormalErrorCondition"
    end
  end

  def set_paragraph_style_name(a_paragraph, style_name)
    a_paragraph.node.children[0].children[0].attributes['val'].value = style_name
  end


  #################################################
  # A apragraph consists of one or more text_runs
  # A paragraph has a style
  # A text_run has a consistent style

  def get_character_styles(para)
    # ap para

    character_styles = []

    para.text_runs.each do |tr|

      begin
        # SMELL: an xpath may be easier to maintain
        name    = tr.node.children[0].children[0].name
      rescue # Exception => e
        #puts "ERROR: #{e}"
        #ap tr.node.children[0]  # .children[0]
        #style = "text"
        name    = tr.node.children[0].name
      end

      if 'rStyle' == name
        # SMELL: an xpath may be easier to maintain
        style   = tr.node.children[0].children[0].attributes.first.last.value
        character_styles << style
      end

    end # of para.text_runs.each do |tr|

    return character_styles

  end # end of def get_character_styles(para)


end # module DocxHelpers
