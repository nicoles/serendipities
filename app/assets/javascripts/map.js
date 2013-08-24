function Map(id){
  this.id = id;
  this.leaflet = L.map('map'); // .setView([37.775, -122.418], 13);
  this.tiles = L.tileLayer.provider('Stamen.TonerLite');
  this.svg = d3.select(this.leaflet.getPanes().overlayPane).append("svg");
  this.g = this.svg.append("g").attr("class", "leaflet-zoom-hide");

  this.tiles.addTo(this.leaflet);
  this.segments = [];
  this.places = [];
  this.activities = [];
}

// {"type":"FeatureCollection",
// "features":[{
//   "type":"Feature",
//   "geometry":{
//     "type":"MultiPolygon",
//     "coordinates":[[[[74.92,37.24],[74.57,37.0

Map.prototype.drawDay = function(day){
  if (!day.segments) return this;
  this.segments = day.segments;
  if (this.leaflet.hasLayer(this.dayLayer)){
    this.dayLayer.clearLayers();
  }
  this.dayLayer = L.featureGroup();

  this.segments.forEach(function(segment){
    if (segment.place) this.addPlace(segment.place);
    if (segment.activities) this.addActivitiesSegment(segment);
  }, this);

  this.dayLayer.addTo(this.leaflet);
  this.leaflet.fitBounds(this.dayLayer.getBounds());
};

Map.prototype.addActivitiesSegment = function(segment){
  this.activities = this.activities.concat(segment.activities);
  segment.activities.forEach(function(activity){
    this.addActivity(activity);
  }, this);
};

Map.ActivityColors = {
  'wlk':'#ff00ff',
  'trp':'black',
  'cyc':'#00ffff',
  'run':'#ffff00'
};

Map.prototype.addActivity = function(activity){
  var trackPoints, color;

  trackPoints = activity.trackPoints.map(function(trackPoint){
    return new L.LatLng(trackPoint.lat,trackPoint.lon);
  });

  color = Map.ActivityColors[activity.activity] || 'gray';
  L.polyline(trackPoints, {color: color}).addTo(this.dayLayer);
};

Map.prototype.addPlace = function(place){
  if (place.name)
    L.marker([place.location.lat, place.location.lon],{title:place.name}).addTo(this.dayLayer);
  else
    L.circle([place.location.lat, place.location.lon],10).addTo(this.dayLayer);
};


$(function(){

  map = new Map('map');

  $('#map-date').submit(function(event) {
    event.preventDefault();
    var date = $(this).find('input.date').val();

    var request = $.ajax({
      method: 'GET',
      url: '/mapdata',
      dataType: 'json',
      data: {date:date}
    });

    request.done(function(data){
      map.drawDay(data);
    });
  });
});