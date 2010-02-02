// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){
    
    $.fn.centerScreen = function(loaded) {
        var obj = this;
        if(!loaded) {
            obj.css('top', $(window).height()/2-this.height()/2);
            obj.css('left', $(window).width()/2-this.width()/2);
            $(window).resize(function() { obj.centerScreen(!loaded); });
        } else {
            obj.stop();
            obj.animate({ top: $(window).height()/2-this.height()/2, left: $
            (window).width()/2-this.width()/2}, 200, 'linear');
        }
    } 
   
   // Login interface
   $('#login_button').click(function(){
       $('#login-buttons').hide();
       $('#login').show();
   });
   
   $('#login_cancel_button').click(function(){
       $('#login').hide();
       $('#login-buttons').show();
   });
   
   $('.regular_button').click(function(){
      $('#openid').hide();
      $('#standard').show();
   });
   
   $('.openid_button').click(function(){
      $('#standard').hide();
      $('#openid').show();
   });
   
  $('#user_openid_identifier').coolinput({
    blurClass: 'blur',
    iconClass: 'openid_icon'
  });
  
  $('#user_email, #user_password').coolinput({
    blurClass: 'blur'
  });
  
  // KARMA!
  $('#karma-tabs').tabs({
      collapsible: true
  });

   
   // Taxatoy-like navigation
   $('#kingdom-dropdown').change(function() {
      // Disable all dropdowns to the right of phylum.
      $('#class-dropdown').attr('disabled', 'disabled');
      $('#order-dropdown').attr('disabled', 'disabled');
      $('#family-dropdown').attr('disabled', 'disabled');
      $('#genus-dropdown').attr('disabled', 'disabled');
      $('#species').fadeOut();
      
      // If someone selects 'any'
      if ($('#kingdom-dropdown').val() == '') {
          
          $('#phylum-dropdown').attr('disabled', 'disabled');
          
          $('#spinner').fadeIn();
          
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#spinner').fadeOut();
              }
          });
          
      } else {
          
          $('#spinner').fadeIn();
          
          // Populate the phylum dropdown.
          $.ajax({
              type: 'GET',
              url: '/taxonomy/dropdown/phylums', 
              data: { parent_id: $('#kingdom-dropdown').val() },
              success: function(response) {
                  $('#phylum-dropdown').html(response);
              }
          });

          // Enable the phylum dropdown.
          $('#phylum-dropdown').removeAttr('disabled');
      
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#kingdom-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#phylum-dropdown').parent().effect('highlight', {}, 500);
                  $('#spinner').fadeOut();
              }
          });
      
      }
      
   });
   
   
   
   
   
   $('#phylum-dropdown').change(function() {
      // Disable all dropdowns to the right of class.
      $('#order-dropdown').attr('disabled', 'disabled');
      $('#family-dropdown').attr('disabled', 'disabled');
      $('#genus-dropdown').attr('disabled', 'disabled');
      $('#species').fadeOut();
      
      // If someone selects 'any'
      if ($('#phylum-dropdown').val() == '') {
          
          $('#class-dropdown').attr('disabled', 'disabled');
          $('#spinner').fadeIn();
          
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#kingdom-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#spinner').fadeOut();
              }
          });
          
      } else {
          $('#spinner').fadeIn();
      
          // Populate the class dropdown.
          $.ajax({
              type: 'GET',
              url: '/taxonomy/dropdown/classes', 
              data: { parent_id: $('#phylum-dropdown').val() },
              success: function(response) {
                  $('#class-dropdown').html(response);
              }
          });

          // Enable the class dropdown.
          $('#class-dropdown').removeAttr('disabled');
      
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#phylum-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#class-dropdown').parent().effect('highlight', {}, 500);
                  $('#spinner').fadeOut();
              }
          });
      
      }
      
   });
   
   
   
   
   
   $('#class-dropdown').change(function() {
      // Disable all dropdowns to the right of class.
      $('#family-dropdown').attr('disabled', 'disabled');
      $('#genus-dropdown').attr('disabled', 'disabled');
      $('#species').fadeOut();
      
      // If someone selects 'any'
      if ($('#class-dropdown').val() == '') {
          
          $('#order-dropdown').attr('disabled', 'disabled');
          $('#spinner').fadeIn();
          
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#phylum-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#spinner').fadeOut();
              }
          });
          
      } else {
          $('#spinner').fadeIn();
      
          // Populate the order dropdown.
          $.ajax({
              type: 'GET',
              url: '/taxonomy/dropdown/orders', 
              data: { parent_id: $('#class-dropdown').val() },
              success: function(response) {
                  $('#order-dropdown').html(response);
              }
          });

          // Enable the order dropdown.
          $('#order-dropdown').removeAttr('disabled');
      
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#class-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#order-dropdown').parent().effect('highlight', {}, 500);
                  $('#spinner').fadeOut();
              }
          });
      
      }
      
   });
   
   
   
   
   
   $('#order-dropdown').change(function() {
      // Disable all dropdowns to the right of family.
      $('#genus-dropdown').attr('disabled', 'disabled');
      $('#species').fadeOut();
      
      // If someone selects 'any'
      if ($('#order-dropdown').val() == '') {
          
          $('#family-dropdown').attr('disabled', 'disabled');
          $('#spinner').fadeIn();
          
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#class-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#spinner').fadeOut();
              }
          });
          
      } else {
          $('#spinner').fadeIn();
      
          // Populate the family dropdown.
          $.ajax({
              type: 'GET',
              url: '/taxonomy/dropdown/families', 
              data: { parent_id: $('#order-dropdown').val() },
              success: function(response) {
                  $('#family-dropdown').html(response);
              }
          });

          // Enable the family dropdown.
          $('#family-dropdown').removeAttr('disabled');
      
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#order-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#family-dropdown').parent().effect('highlight', {}, 500);
                  $('#spinner').fadeOut();
              }
          });
      
      }
      
   });
   
   
   
   
   
   
   $('#family-dropdown').change(function() {
      
      $('#species').fadeOut();
       
      // If someone selects 'any'
      if ($('#family-dropdown').val() == '') {
          
          $('#genus-dropdown').attr('disabled', 'disabled');
          $('#spinner').fadeIn();
          
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#order-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#spinner').fadeOut();
              }
          });
          
      } else {
          $('#spinner').fadeIn();
       
          // Populate the genus dropdown.
          $.ajax({
              type: 'GET',
              url: '/taxonomy/dropdown/genuses', 
              data: { parent_id: $('#family-dropdown').val() },
              success: function(response) {
                  $('#genus-dropdown').html(response);
              }
          });

          // Enable the genus dropdown.
          $('#genus-dropdown').removeAttr('disabled');
      
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#family-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#genus-dropdown').parent().effect('highlight', {}, 500);
                  $('#spinner').fadeOut();
              }
          });
      
      }
      
   });
   
   
   
   
   
   
   
   $('#genus-dropdown').change(function() {
       
      $('#species').fadeOut();
       
       // If someone selects 'any'
      if ($('#genus-dropdown').val() == '') {
          $('#spinner').fadeIn();
          
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#family-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#spinner').fadeOut();
              }
          });
          
      } else {
          $('#spinner').fadeIn();
      
          // Update the main page content.
          $.ajax({
              type: 'GET',
              url: '/species/data', 
              data: { 'taxon_id': $('#genus-dropdown').val() },
              success: function(response) {
                  $('#species').html(response);
                  $('#species').fadeIn();
                  $('#spinner').fadeOut();
              }
          });
      
      }
      
    });
    
    $('#create-species').click(function() {
       $("#backgroundGray").fadeIn(3000);
       $('#popup').centerScreen();
       $("#popup").fadeIn(5000);
    });
    
});
