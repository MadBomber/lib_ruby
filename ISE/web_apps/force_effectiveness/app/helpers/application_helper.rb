# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # These functions aren't used, so can be deleted when no longer needed as examples.
  def toggle_link_for_div(div_id, link_id)

    link_to_function( 
    "[-] ", 
    "if ($('" + link_id + "').innerHTML == '[-] ') 
              { 
                $('" + link_id + "').update('[+] '); 
              } else { 
                $('" + link_id + "').update('[-] ');
              }; 
              $('" + div_id + "').toggle(); 
              Modalbox.resizeToInclude(); ", 
    :id => link_id, 
    :style => 'display: none')
  end

  def   modalbox_function(controller,override_id, action, title)

    'Modalbox.show("' + 
    url_for(
    :controller => controller, 
    :action => action,
    :id=>0, 
    :popup => true,

    :override_id => override_id) + 
    '", {width: 1100, title: "' + title + '"})'

  end

  def modalbox_function_edit(controller, override_id, action, id, title)
    link_to_function(
    'Edit', 
    modalbox_function(controller,override_id, action, title),
    :id=> id)
  end

  def modalbox_function_new(controller, override_id, action, id, title)
    link_to_function(
    'New', 
    modalbox_function(controller,override_id, action, title),
    :id=> id)
  end

end
