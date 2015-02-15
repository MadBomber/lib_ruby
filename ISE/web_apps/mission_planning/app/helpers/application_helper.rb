# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  require 'pp'
  
  #################################
  def toggle_link_for_div(div_id, link_id)    
    s[0] = "if($('" + link_id + "').innerHTML == '[-] ')"
    s[1] = "{"
    s[2] = "  $('" + link_id + "').update('[+] ');"
    s[3] = "} else {"
    s[4] = "  $('" + link_id + "').update('[-] ');"
    s[5] = "};"
    s[6] = ""
    s[7] = "$('" + div_id + "').toggle();"
    s[8] = "Modalbox.resizeToInclude();"
    
    link_to_function("[-] ",
                     s.join("\n"),
                     :id => link_id,
                     :style => 'display: none')
  end
  
  #################################
  def modalbox_function(controller,override_id, action, title)
    u = url_for(:controller => controller,
                :action => action,
                :id=>0,
                :popup => true,
                :override_id => override_id)
    
    return 'Modalbox.show("' + u + '", {width: 1100, title: "' + title + '"})'
  end
  
  #################################
  def modalbox_function_edit(controller, override_id, action, id, title)
    s = modalbox_function(controller, override_id, action, title)
    
    link_to_function('Edit', s, :id=> id)
  end
  
  #################################
  def modalbox_function_new(controller, override_id, action, id, title)
    s = modalbox_function(controller, override_id, action, title)
    
    link_to_function('New', s, :id=> id)
  end
  
  #################################
  def add_form_field(f, association, local_variables = nil)
    new_object = f.object.class.reflect_on_association(association).klass.new
    
    pp new_object
        
    parent_sym = f.object.class.name.underscore.to_sym
    
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      if local_variables
        render(association.to_s + "/new_form", :f => builder, parent_sym => f.object, :local_variables => local_variables)
      else
        render(association.to_s + "/new_form", {:f => builder, parent_sym => f.object})
      end
    end
    
    # FIXME: Not working yet.
    #render :partial => association.to_s + "/new_form"
  end
  
  #################################
  def button_to_add_form_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    
    parent_sym = f.object.class.name.underscore.to_sym
        
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s + "/new_form", :f => builder, parent_sym => f.object)
    end
    
    button_to_function(name, h("add_form_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end
  
  #################################
  def button_to_remove_form_fields(name, f)
    # NOTE: The attribute must be "_delete" not "_destroy"!
    #	    It appears that _destroy was used previously and that it switched
    #		breifly to _delete in Rails 2.3.2.  In 2.3.4 it is returned back to
    #		_destroy as depricated.  The current understanding is that _delete
    #		will be used for future implementations.
	
    f.hidden_field(:_delete) + button_to_function(name, "remove_form_fields(this)")
  end
  
  
  
  #################################
  def get_table_header(columns)
    s = Array.new
    
    # open table row
    s << '<tr class=header_row>'
    
    # add attribute headers
    columns.each do |column|
      str = remove_mp_prefix(column)
      
      str = 'description' if str == 'desc'
      
      s << "  <th class=padded>#{str.titleize}</th>"
    end
    
    # add actions column
    s << "  <th class=wider>Actions</th>"
    
    # close table row
    s << '</tr>'
    
    return s.join("\n")
  end
  
  #################################
  def get_table_row_contents(model_entry, columns)
    s = Array.new
    
    # add each table cell
    columns.each do |column|
      s << "  <td>#{get_table_cell_contents(model_entry, column)}</td>"
    end ## columns.each do |column|
    
    return s.join("\n")
  end
  
  #################################
  def get_table_columns(param)
    uninteresting_columns = ['id', 'created_at', 'updated_at']
    
    model_class = get_associated_class(param)
    
    if model_class.respond_to?('column_names')
      return model_class.column_names - uninteresting_columns
    else
      return nil
    end
  end
  
  
  ################################################
  ## TODO: Declare a convention that if a column name ends with
  ##       "_file" that when it is displayed, it will be
  ##       as part of a hyperlink that allows the user to
  ##       download the file.
  
  def get_table_cell_contents(model_entry, column)
    str = remove_id_suffix(column)
    actual_columns = model_entry.class.column_names
    
    if actual_columns.include?(str)
      cell_contents = model_entry.attributes[str]
    elsif actual_columns.include?(str.foreign_key)
      foreign_object = model_entry.method(str).call
      cell_contents = link_to(foreign_object.name, foreign_object)
    else
      result = model_entry.method(str).call
        
      if result.class == Array
        foreign_objects = result
        cell_contents = ""
        foreign_objects.each do |foreign_object|
          cell_contents += "  #{link_to(foreign_object.attributes['name'], foreign_object)} |"
        end
        cell_contents.chomp!(' |')
      end ## if cell_contents.class == Array
    end ## if actual_columns.include?(str)

    # TODO: trap the "selected" column from the scenarios table; replace
    #       true/false with an image to indicate that it is either
    #       selected (checkmark) or unslected (something blank).
    
    return cell_contents
  end
  
  ##################################
  ## get root path symbol for class
  def class_path_sym(param, action = nil)
    str = class_path_str(param, action).dup
    return str.chomp!('_path').to_sym
  end
  
  #################################
  ## get root path string for class
  def class_path_str(param, action = nil)
    return "#{action.nil? ? nil : action + '_'}#{get_associated_class(param).class_name.underscore}_path"
  end
  
  #################################
  def root_class_path_sym(param)
    sym = class_path_sym(param)
    return (sym.to_s.pluralize).to_sym
  end
  
  #################################
  ## get root name from class
  def simple_name(param)
    return remove_mp_prefix(table_name(param))
  end
  
  #################################
  def table_name(param)
    model_class = get_associated_class(param)
    
    if model_class.respond_to?('table_name')
      return model_class.table_name
    else
      puts "#{param} didn't respond to table!"
      return nil
    end
  end
  
  #################################
  def get_associated_class(param)
    param = eval(remove_id_suffix(param).classify) if param.class == String
    
    if param.class == Class
      return param
    else
      return param.class
    end
  end
  
  #################################
  def remove_mp_prefix(name)
    return remove_prefix(name, ['Mp', 'mp_'])
  end
  
  #################################
  def remove_id_suffix(name)
    return remove_suffix(name, '_id')
  end
  
  #################################
  def remove_prefix(str, prefixes)
    temp_str = str.dup
    prefixes = Array(prefixes)
    
    prefixes.each do |prefix|
      if str.first(prefix.length) == prefix
        temp_str.slice!(prefix)
        break
      end
    end
    
    return temp_str
  end
  
  #################################
  def remove_suffix(str, suffixes)
    temp_str = str.dup
    suffixes = Array(suffixes)
    
    suffixes.each do |suffix|
      if str.last(suffix.length) == suffix
        temp_str.chomp!(suffix)
        break
      end
    end
    
    return temp_str
  end
end
