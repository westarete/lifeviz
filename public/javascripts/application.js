// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
   
   $('#login_button').click(function(){
       $('#login').show("slow");
   });
   
   $('#login_cancel_button').click(function(){
       $('#login').hide("slow");
   })
    
});