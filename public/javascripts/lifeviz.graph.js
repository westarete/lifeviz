function build_graph(data) {

  // The units and dimensions to visualize, in order.
  var units = {
    avg_lifespan:       {name: "lifespan", unit: " days"},
    avg_birth_weight:   {name: "birth weight", unit: " g"},
    avg_adult_weight:   {name: "adult weight", unit: " g"},
    avg_litter_size:    {name: "litter size", unit: ""}
  }

  var dims = pv.keys(units);

  /* Sizing and scales. */
  var w = 820,
      h = 420,
      fudge = 0.5,
      x = pv.Scale.ordinal(dims).splitFlush(0, w),
      y = pv.dict(dims, function(t) pv.Scale.linear(  
          data.filter(function(d) !isNaN(d[t])),
          function(d) Math.floor(d[t])-fudge,
          function(d) Math.ceil(d[t]) +fudge
          ).range(0, h)),
      c = pv.dict(dims, function(t) pv.Scale.linear(
          data.filter(function(d) !isNaN(d[t])),
          function(d) Math.floor(d[t])-fudge,
          function(d) Math.ceil(d[t]) +fudge
          ).range("steelblue", "brown"));

  /* Interaction state. */
  var filter = pv.dict(dims, function(t) {
      return {min: y[t].domain()[0], max: y[t].domain()[1]};
    }), active = "avg_lifespan";

  /* The root panel. */
  var vis = new pv.Panel()
      .width(w)
      .height(h)
      .left(30)
      .right(30)
      .top(30)
      .bottom(20)
      .canvas('graph'); // where to put it

  // The parallel coordinates display.
  vis.add(pv.Panel)
      .data(data)
      .visible(function(d) dims.every(function(t)
          (d[t] >= filter[t].min) && (d[t] <= filter[t].max)))
    .add(pv.Line)
      .data(dims)
      .left(function(t, d) x(t))
      .bottom(function(t, d) y[t](d[t]))
      .strokeStyle("#ddd")
      .lineWidth(1)
      .antialias(false);

  // Rule per dimension.
  rule = vis.add(pv.Rule)
      .data(dims)
      .left(x);

  // Dimension label
  rule.anchor("top").add(pv.Label)
      .top(-12)
      .font("bold 10px sans-serif")
      .text(function(d) units[d].name);

  // The parallel coordinates display.
  var change = vis.add(pv.Panel);

  var line = change.add(pv.Panel)
      .data(data)
      .visible(function(d) dims.every(function(t)
          (d[t] >= filter[t].min) && (d[t] <= filter[t].max)))
    .add(pv.Line)
      .data(dims)
      .left(function(t, d) x(t))
      .bottom(function(t, d) y[t](d[t]))
      .strokeStyle(function(t, d) c[active](d[active]))
      .lineWidth(1);

  // Updater for slider and resizer.
  function update(d) {
    var t = d.dim;
    filter[t].min = Math.max(y[t].domain()[0], y[t].invert(h - d.y - d.dy));
    filter[t].max = Math.min(y[t].domain()[1], y[t].invert(h - d.y));
    active = t;
    change.render();
    return false;
  }

  // Updater for slider and resizer.
  function selectAll(d) {
    if (d.dy < 3) {
      var t = d.dim;
      filter[t].min = Math.max(y[t].domain()[0], y[t].invert(0));
      filter[t].max = Math.min(y[t].domain()[1], y[t].invert(h));
      d.y = 0; d.dy = h;
      active = t;
      change.render();
    }
    return false;
  }

  /* Handle select and drag */
  var handle = change.add(pv.Panel)
      .data(dims.map(function(dim) { return {y:0, dy:h, dim:dim}; }))
      .left(function(t) x(t.dim) - 30)
      .width(60)
      .fillStyle("rgba(0,0,0,.001)")
      .cursor("crosshair")
      .event("mousedown", pv.Behavior.select())
      .event("select", update)
      .event("selectend", selectAll)
    .add(pv.Bar)
      .left(25)
      .top(function(d) d.y)
      .width(10)
      .height(function(d) d.dy)
      .fillStyle(function(t) t.dim == active
          ? c[t.dim]((filter[t.dim].max + filter[t.dim].min) / 2)
          : "hsla(0,0,50%,.5)")
      .strokeStyle("white")
      .cursor("move")
      .event("mousedown", pv.Behavior.drag())
      .event("dragstart", update)
      .event("drag", update);

  handle.anchor("bottom").add(pv.Label)
      .textBaseline("top")
      .text(function(d) filter[d.dim].min.toFixed(0) + units[d.dim].unit);

  handle.anchor("top").add(pv.Label)
      .textBaseline("bottom")
      .text(function(d) filter[d.dim].max.toFixed(0) + units[d.dim].unit);

  vis.render();
}

$(function(){
  var li = $(this).parent(); // used to track which rank is shown
  var taxon_id = $('#graph').attr('taxon_id');
  var data = $.ajax({ type: "GET", url: '/species/data.json', data: {taxon_id: taxon_id}, async: false }).responseText;
  data = JSON.parse(data);
  
  // build initial graph
  build_graph(data);

  $('#taxonomic_selector select').live('change', function(){
    // delete all sibblings after $(this)
    var li = $(this).parent();
    var selected_id = $(this).val();
    var species_id = selected_id;
    
    $('.spinner').fadeIn();
    
    // If the user selects "All", then we get the value of the parent selection box
    // If we're at the Kingdom level (no parent select box), we set it to the ubiota id of UBT
    if(!selected_id) {
      var parent_id = li.prev().children("select").val();
      if(parent_id === undefined) {
        species_id = 1; // UBT
      } else {
        species_id = parent_id;
      }
    } else {
      species_id = selected_id;
    }
    
    li.nextAll().remove();

    // Send out an XHR to load the next taxonomic selector dropdown
    // Unless the user has selected "All", or is at the species level,
    var taxa_timeout;
    if(selected_id && !li.hasClass('rank_4') ) {
      $.ajax({
        url: '/species/' + species_id + '/children',
        beforeSend: function(){
          taxa_timeout = setTimeout(function(){ 
            li.addClass('loading');
          }, 500);   
        },
        success: function(response){
          li.after(response);
        },
        complete: function(err){
          clearTimeout(taxa_timeout);
          $('#navigation_spinner').fadeOut();
        }
      });
    }
    
    // Send out an XHR to fetch data to update the graph
    var url = '/species/data.json';
    var graph_timeout;
    $.ajax({
      url: url,
      data: { taxon_id: species_id },
      beforeSend: function(){
        graph_timeout = setTimeout(function(){ 
          $("#title").addClass('loading');
        }, 500);
      },
      success: function(json_response) {
        if(json_response.length > 0) {
          data = JSON.parse(json_response);
          build_graph(data);
        } 
      },
      complete: function () {
        clearTimeout(graph_timeout);
        $('#graph_spinner').fadeOut();
      }
    });

    // Update the main page content.
    $.ajax({
        type: 'GET',
        url: '/species/data', 
        data: { 'taxon_id': species_id },
        success: function(response) {
            $('#species').html(response);
            $('#species').fadeIn();
            $('#species_spinner').fadeOut();
        }
    });
    
  });
});