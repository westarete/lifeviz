// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
   
   $('#login_button').click(function(){
       $('#login').show("slow");
   });
   
   $('#login_cancel_button').click(function(){
       $('#login').hide("slow");
   })
   
   $('#kingdom-dropdown').change(function() {
      // Disable all dropdowns to the right of phylum.
      $('#class-dropdown').attr('disabled', 'disabled');
      $('#order-dropdown').attr('disabled', 'disabled');
      $('#family-dropdown').attr('disabled', 'disabled');
      $('#genus-dropdown').attr('disabled', 'disabled');
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
          data: { 'taxon': $('#kingdom-dropdown').val() },
          success: function(response) {
              $('#species').html(response);
          }
      });
      
   });
   
   
   
   
   
   $('#phylum-dropdown').change(function() {
      // Disable all dropdowns to the right of class.
      $('#order-dropdown').attr('disabled', 'disabled');
      $('#family-dropdown').attr('disabled', 'disabled');
      $('#genus-dropdown').attr('disabled', 'disabled');
      // Populate the phylum dropdown.
      $.ajax({
          type: 'GET',
          url: '/taxonomy/dropdown/classes', 
          data: { parent_id: $('#phylum-dropdown').val() },
          success: function(response) {
              $('#class-dropdown').html(response);
              $('#class-dropdown').parent().effect('highlight', {}, 500);
          }
      });

      // Enable the phylum dropdown.
      $('#class-dropdown').removeAttr('disabled');
      
      // Update the main page content.
      $.ajax({
          type: 'GET',
          url: '/species/data', 
          data: { 'taxon': $('#phylum-dropdown').val() },
          success: function(response) {
              $('#species').html(response);
          }
      });
      
   });
   
   
   
   
   
   $('#class-dropdown').change(function() {
      // Disable all dropdowns to the right of class.
      $('#family-dropdown').attr('disabled', 'disabled');
      $('#genus-dropdown').attr('disabled', 'disabled');
      // Populate the phylum dropdown.
      $.ajax({
          type: 'GET',
          url: '/taxonomy/dropdown/orders', 
          data: { parent_id: $('#class-dropdown').val() },
          success: function(response) {
              $('#order-dropdown').html(response);
              $('#order-dropdown').parent().effect('highlight', {}, 500);
          }
      });

      // Enable the phylum dropdown.
      $('#order-dropdown').removeAttr('disabled');
      
      // Update the main page content.
      $.ajax({
          type: 'GET',
          url: '/species/data', 
          data: { 'taxon': $('#class-dropdown').val() },
          success: function(response) {
              $('#species').html(response);
          }
      });
      
   });
   
   
   
   
   
   $('#order-dropdown').change(function() {
      // Disable all dropdowns to the right of family.
      $('#genus-dropdown').attr('disabled', 'disabled');
      // Populate the phylum dropdown.
      $.ajax({
          type: 'GET',
          url: '/taxonomy/dropdown/families', 
          data: { parent_id: $('#order-dropdown').val() },
          success: function(response) {
              $('#family-dropdown').html(response);
              $('#family-dropdown').parent().effect('highlight', {}, 500);
          }
      });

      // Enable the phylum dropdown.
      $('#family-dropdown').removeAttr('disabled');
      
      // Update the main page content.
      $.ajax({
          type: 'GET',
          url: '/species/data', 
          data: { 'taxon': $('#order-dropdown').val() },
          success: function(response) {
              $('#species').html(response);
          }
      });
      
   });
   
   
   
   
   
   $('#genus-dropdown').change(function() {
      
      // Update the main page content.
      $.ajax({
          type: 'GET',
          url: '/species/data', 
          data: { 'taxon': $('#genus-dropdown').val() },
          success: function(response) {
              $('#species').html(response);
          }
      });
      
   });
   
});