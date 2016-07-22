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

  this.segments.forEach(function(segment){
    if (segment.place) this.addPlaceSegment(segment);
    if (segment.activities) this.addActivitiesSegment(segment);
  }, this);

  this.dayLayer.addTo(this.leaflet);
  this.leaflet.fitBounds(this.dayLayer.getBounds());
};

Map.prototype.drawDates = function(data){
  if (!data.dates) return this;
  this.dates = data.dates;
  if (this.leaflet.hasLayer(this.dayLayer)){
    this.dayLayer.clearLayers();
  }
  this.dayLayer = L.featureGroup();
  $.each(data.dates, function(index, date){
    map.drawDay(date);
  });
};

Map.prototype.addPlaceSegment = function(segment){

};

Map.prototype.addActivitiesSegment = function(segment){
  this.activities = this.activities.concat(segment.activities);
  segment.activities.forEach(function(activity){
    this.addActivity(activity);
  }, this);
};

Map.ActivityColors = {
  'wlk':'green',
  'trp':'black',
  'cyc':'blue',
  'run':'red'
};

Map.prototype.addActivity = function(activity){
  var trackPoints, color;

  trackPoints = activity.trackPoints.map(function(trackPoint){
    return new L.LatLng(trackPoint.lat,trackPoint.lon);
  });

  color = Map.ActivityColors[activity.activity] || 'gray';
  L.polyline(trackPoints, {color: color}).addTo(this.dayLayer);
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

    request.done(function(data){
      map.drawDates(data);
    });
  });
});


$(window).resize(function(){
  var height = $(window).height();
  var scale = 0.9;
  $(".map").css('height', height * scale);
});



