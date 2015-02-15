/**
 * @author edietz
 */

 function aadse_steps_enable_step (step_class_name)
 {
 	elements_with_class_name = $$('.' + step_class_name);

 	for (i = 0; i < elements_with_class_name.length; i++)
	{
		elements_with_class_name[i].writeAttribute('disabled', null)	
	}
	
	return;
 }
 
 function aadse_steps_disable_all_except (step_class_name)
 {
 	elements_with_class_name = $$('.steps');
	
	for (i = 0; i < elements_with_class_name.length; i++)
	{
		aadse_steps_disable_element(elements_with_class_name[i]);
	
	}
	aadse_steps_enable_step(step_class_name);
	
	return;
 }
 
 function aadse_steps_disable_step(step_class_name)
 {
 	elements_with_class_name = $$('.' + step_class_name);
	
	for (i = 0; i < elements_with_class_name.length; i++)
	{
		aadse_steps_disable_element(elements_with_class_name[i]);
	}
 }
 
 function aadse_steps_disable_element(el) {
	
	if ((el.readAttribute('type') == 'button')  || (el.identify().search('_id') >= 0))
	{
		el.writeAttribute('disabled');
	}
	else 
	{
		if (el.identify().search('status') >= 0) 
		{
			el.update("[N/A]");
		}
	}
 }
 
function aadse_flotr_update_pie(div_id, raw_json)
{
	try 
	{
		var json = raw_json.evalJSON(true); 
		var f = Flotr.draw($(div_id), json.series, json.options);
	} catch (e1) 
	{
		alert(e1)
	}
	
}
