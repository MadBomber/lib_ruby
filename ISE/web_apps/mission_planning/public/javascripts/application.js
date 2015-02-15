// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function remove_form_fields(link) {
  $(link).previous("input[type=hidden]").value = "1";
  $(link).up(".form_fields").hide();
}  


function add_form_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(link).up().insert({
    before: content.replace(regexp, new_id)
  });
}  