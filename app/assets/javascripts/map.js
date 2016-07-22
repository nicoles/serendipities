var mapboxgl = require('mapbox-gl');
mapboxgl.accessToken = $('head').data('mapbox_token');

function Map(id){
  this.id = id;
  this.mapbox = new mapboxgl.Map({
    container: this.id,
    style: 'mapbox://styles/mapbox/light-v9',
    center: [-122.4, 37.8], // starting position
    zoom: 11 // starting zoom
  });
  this.dates = [];
  this.segments = [];
  this.activities =[];
  this.sources =[];

}

Map.prototype.removeSources = function(sources){
  // TODO doesn't work yet :(
  $.each(sources, function(source){
    map.mapbox.removeLayer(source);
    map.mapbox.removeSource(source);
  });
  map.sources =[];
};

Map.prototype.buildSources = function(features){
  $.each(features, function(index, feature){
    map.mapbox.addSource(feature.properties.type, {
      "type": "geojson",
      "data": feature
    });
    map.sources.push(feature.properties.type);
  });
};

Map.prototype.renderLayers = function(features){
  $.each(features, function(index, feature){
    map.mapbox.addLayer({
      "id": feature.properties.type,
      "source": feature.properties.type,
      "type": "line",
      "layout": {
        "line-join": "round",
        "line-cap": "round"
      },
      "paint": {
        "line-color": feature.properties.color,
        "line-width": 1,
        "line-opacity": 0.7
      }
    });
  });
};

// on dom~~
$(function(){
  map = new Map('map');

  var height = $(window).height();
  var scale = 0.9;
  $(".map").css('height', height * scale);

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
      if(map.sources.length) map.removeSources(map.sources);
      map.buildSources(result);
      map.renderLayers(result);
    });
  });
});

$(window).resize(function(){
  var height = $(window).height();
  var scale = 0.9;
  $(".map").css('height', height * scale);
});



