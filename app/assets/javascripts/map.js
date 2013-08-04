Map = {};

Map.initialize = function(){
  this.map = L.map('map').setView([37.775, -122.418], 13);
  L.tileLayer.provider('Stamen.Toner').addTo(this.map);

  var points = [];
  data[0].segments.forEach(function(segment){
    var lat, lng;
    if (segment.place){
      lat = segment.place.location.lat;
      lng = segment.place.location.lon;
      points.push(new L.LatLng(lat,lng));
    }
    if (segment.activities){
      segment.activities.forEach(function(activity){
        activity.trackPoints.forEach(function(trackPoint){
          lat = trackPoint.lat;
          lng = trackPoint.lon;
          points.push(new L.LatLng(lat,lng));
        });
      });
    }
  });
  // create a red polyline from an arrays of LatLng points
  var polyline = L.polyline(points, {color: 'red'}).addTo(this.map);

  // zoom the map to the polyline
  // this.map.fitBounds(polyline.getBounds());
};


$(function(){
  Map.initialize();
});
