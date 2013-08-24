function Map(id){
  this.id = id;
  this.leaflet = L.map('map');
  this.tiles = L.tileLayer.provider('Stamen.TonerLite');

  this.tiles.addTo(this.leaflet);
  this.segments = [];
  this.activities = [];
}

Map.prototype.drawDay = function(day){
  if (!day.segments) return this;
  this.segments = day.segments;
  if (this.leaflet.hasLayer(this.dayLayer)){
    this.dayLayer.clearLayers();
  }
  this.dayLayer = L.featureGroup();

  this.segments.forEach(function(segment){
    if (segment.place) this.addPlaceSegment(segment);
    if (segment.activities) this.addActivitiesSegment(segment);
  }, this);

  this.dayLayer.addTo(this.leaflet);
  this.leaflet.fitBounds(this.dayLayer.getBounds());
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




