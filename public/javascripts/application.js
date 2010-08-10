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
  
  
  
});

