var mapboxgl = require('mapbox-gl');
mapboxgl.accessToken = 'pk.eyJ1Ijoibmljb2xlcyIsImEiOiJjaW9qOXQxdjcwMGVpdTVtMWltZGowZWt3In0.i3Vkkt42Qzx3BMNvbAxQ6Q';

function Map(id){
  var mapbox = new mapboxgl.Map({
      container: id,
      style: 'mapbox://styles/mapbox/light-v9'
  });
}

// function Map(id){
//   this.id = id;
//   this.leaflet = L.map('map');
//   this.tiles = L.tileLayer.provider('Stamen.TonerLite');

//   this.tiles.addTo(this.leaflet);
//   this.dates = [];
//   this.segments = [];
//   this.activities = [];
// }

// Map.prototype.drawDay = function(day){
//   day = $.parseJSON(day);
//   if (!day.segments) return this;
//   this.segments = day.segments;


//   this.segments.forEach(function(segment){
//     if (segment.place) this.addPlaceSegment(segment);
//     if (segment.activities) this.addActivitiesSegment(segment);
//   }, this);

//   this.dayLayer.addTo(this.leaflet);
//   this.leaflet.fitBounds(this.dayLayer.getBounds());
// };

// Map.prototype.drawDates = function(data){
//   if (!data.dates) return this;
//   this.dates = data.dates;
//   if (this.leaflet.hasLayer(this.dayLayer)){
//     this.dayLayer.clearLayers();
//   }
//   this.dayLayer = L.featureGroup();
//   $.each(data.dates, function(index, date){
//     map.drawDay(date);
//   });
// };

// Map.prototype.addPlaceSegment = function(segment){

// };

// Map.prototype.addActivitiesSegment = function(segment){
//   this.activities = this.activities.concat(segment.activities);
//   segment.activities.forEach(function(activity){
//     this.addActivity(activity);
//   }, this);
// };

// Map.ActivityColors = {
//   'wlk':'green',
//   'trp':'black',
//   'cyc':'blue',
//   'run':'red'
// };

// Map.prototype.addActivity = function(activity){
//   var trackPoints, color;

//   trackPoints = activity.trackPoints.map(function(trackPoint){
//     return new L.LatLng(trackPoint.lat,trackPoint.lon);
//   });

//   color = Map.ActivityColors[activity.activity] || 'gray';
//   L.polyline(trackPoints, {color: color}).addTo(this.dayLayer);
// };


$(function(){
  var height = $(window).height();
  var scale = 0.9;
  $(".map").css('height', height * scale);

  map = new Map('map');

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



