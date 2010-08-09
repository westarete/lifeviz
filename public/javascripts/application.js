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

  // Table Sort
  $(".speciestable").tablesorter(); 

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
  
  // // KARMA!
  // $('#karma-tabs').tabs({
  //     collapsible: true
  // });
    
  $('#create-species').click(function() {
     $("#backgroundGray").fadeIn(3000);
     $('#popup').centerScreen();
     $("#popup").fadeIn(5000);
  });
    
});

