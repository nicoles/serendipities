var mapboxgl = require('mapbox-gl');
mapboxgl.accessToken = $('head').data('mapbox_token');

function ExploreMap(id){
  this.id = id;
  this.mapbox = new mapboxgl.Map({
    container: this.id,
    style: 'mapbox://styles/nicoles/cixgqutoo00fs2psfk3ywsrhq',
    center: [-122.4, 37.8], // starting position
    zoom: 11 // starting zoom
  });
  this.dates = [];
  this.segments = [];
  this.activities =[];
  this.sources =[];

}

ExploreMap.prototype.removeSources = function(sources){
  $.each(this.sources, function(index, source){
    exploreMap.mapbox.removeLayer(source);
    exploreMap.mapbox.removeSource(source);
  });
  exploreMap.sources =[];
};

ExploreMap.prototype.buildSources = function(features){
  $.each(features, function(index, feature){
    exploreMap.mapbox.addSource(feature.properties.type, {
      "type": "geojson",
      "data": feature
    });
    exploreMap.sources.push(feature.properties.type);
  });
};

ExploreMap.prototype.renderLayers = function(features){
  $.each(features, function(index, feature){
    exploreMap.mapbox.addLayer({
      "id": feature.properties.type,
      "source": feature.properties.type,
      "type": "line",
      "layout": {
        "line-join": "round",
        "line-cap": "round"
      },
      "paint": {
        "line-color": feature.properties.color,

        "line-opacity": 0.8
      }
    });
  });
};

window.setupExploreMap = function(){
  var $explore = $(".exploreMap");
  if (!$explore.exists()) {
    return;
  }
  window.exploreMap = new ExploreMap('exploreMap');

  var height = $(window).height();
  var scale = 0.9;
  $explore.css('height', height * scale);

  $('#map-date').submit(function(event) {
    event.preventDefault();
    var start_date = $(this).find('input.start').val();
    var end_date = $(this).find('input.end').val();

    var request = $.ajax({
      method: 'GET',
      url: '/mapdata',
      dataType: 'json',
      data: {
        start_date:start_date,
        end_date:end_date,
      }
    });

    request.done(function(result){
      if(exploreMap.sources.length) exploreMap.removeSources(exploreMap.sources);
      exploreMap.buildSources(result);
      exploreMap.renderLayers(result);
    });
  });
};

$(window).resize(function(){
  var height = $(window).height();
  var scale = 0.9;
  $(".exploreMap").css('height', height * scale);
});



