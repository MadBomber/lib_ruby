<% form_remote_tag :update => "fe_multi_box_stats_table", :url => {:controller => 'force_effectiveness', :action => 'get_multi_box_query_stats'},
:html => {:action => {:controller => 'force_effectiveness', :action => 'get_multi_box_query_stats'}} do %>
 <%= @condition_string %>
 
<% form_remote_tag :update => 'stats_chart', :url '/fe_runs/chart' do %>
  <table class='stats_query'>
    <tr>

    </tr>
    
   <tr>
     <td>
       Defended Areas
       <%= select_tag(
           'defended_areas', 
           options_for_select(@da_hash, "ALL"), 
           :multiple => false, 
           :size => 5, 
           :style => 'width: 100%'
         )%>
     </td>
     <td>
       Batteries
       <%= select_tag(
           'batteries', 
           options_for_select(@bat_hash, "ALL"), 
           :multiple=>false, 
           :size => 5, 
           :style=>'width: 100%'
         )%>
     </td>
     <td>
       Threats
       <%= select_tag(
           'threats', 
           options_for_select(@threat_hash, "ALL"), 
           :multiple=>false, 
           :size => 5, 
           :style=>'width: 100%'
         ) %>
     </td>
     <td>
       Intercept Events
       <%= select_tag( 
           'intercept_events', 
           options_for_select(@inter_hash, "ALL"), 
           :multiple=>false, 
           :size => 5, 
           :style=>'width: 100%' 
         )%>
     </td>
   </tr>
 </table>
 
 <%= submit_tag 'Update', :style=>'width: 100%' %>

<% end %>