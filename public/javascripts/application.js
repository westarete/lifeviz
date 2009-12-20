// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
   
   $('#login_button').click(function(){
       $('#login').show("slow");
   });
   
   $('#login_cancel_button').click(function(){
       $('#login').hide("slow");
   })
   
   dropdown_urls = {
     '#kingdom-dropdown': '/taxonomy/dropdown/kingdoms',
     '#phylum-dropdown':  '/taxonomy/dropdown/phylums',
     '#class-dropdown':   '/taxonomy/dropdown/classes',
     '#order-dropdown':   '/taxonomy/dropdown/orders',
     '#family-dropdown':  '/taxonomy/dropdown/families',
     '#genus-dropdown':   '/taxonomy/dropdown/genuses',
   };
   
   $('#kingdom-dropdown').change(function() {
      // Disable all dropdowns to the right of phylum.
      $('#class-dropdown').attr('disabled', 'disabled');
      $('#order-dropdown').attr('disabled', 'disabled');
      $('#family-dropdown').attr('disabled', 'disabled');
      $('#genus-dropdown').attr('disabled', 'disabled');
      $('#species-dropdown').attr('disabled', 'disabled');
      // Populate the phylum dropdown.
      $.ajax({
          type: 'GET',
          url: '/taxonomy/dropdown/phylums', 
          data: { parent_id: $('#kingdom-dropdown').val() },
          success: function(response) {
              $('#phylum-dropdown').html(response);
              $('#phylum-dropdown').parent().effect('highlight', {}, 500);
          }
      });

      // Enable the phylum dropdown.
      $('#phylum-dropdown').removeAttr('disabled');
      
      // Update the main page content.
      $.ajax({
          type: 'GET',
          url: '/species/data', 
          data: { 'kingdom': $('#kingdom-dropdown').val() },
          success: function(response) {
              $('#species').html(response);
          }
      });
      
   });
    
});