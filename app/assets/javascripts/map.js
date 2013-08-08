Map = {};

Map.initialize = function(){
  var myMap = L.map('map').setView([37.775, -122.418], 13);
  L.tileLayer.provider('Stamen.Toner').addTo(myMap);

  var placePoints = [];

  data[0].segments.forEach(function(segment){
    var lat, lng;
    if (segment.place){
      lat = segment.place.location.lat;
      lng = segment.place.location.lon;
      placePoints.push(new L.LatLng(lat,lng));
    }
    if (segment.activities){
      segment.activities.forEach(function(activity){
        //wlk, run, trp, cyc
        if (activity.activity == 'wlk'){
          var walkPoints = [];
          // console.log(this);
          activity.trackPoints.forEach(function(trackPoint){
            lat = trackPoint.lat;
            lng = trackPoint.lon;
            walkPoints.push(new L.LatLng(lat,lng));
          });
          var walkline = L.polyline(walkPoints, {color: 'green'}).addTo(myMap);
        }
        if (activity.activity == 'trp'){
          var tripPoints = [];
          // console.log(this);
          activity.trackPoints.forEach(function(trackPoint){
            lat = trackPoint.lat;
            lng = trackPoint.lon;
            tripPoints.push(new L.LatLng(lat,lng));
          });
          var tripline = L.polyline(tripPoints, {color: 'gray'}).addTo(myMap);
        }
        if (activity.activity == 'cyc'){
          var cyclePoints = [];
          console.log(this);
          activity.trackPoints.forEach(function(trackPoint){
            lat = trackPoint.lat;
            lng = trackPoint.lon;
            cyclePoints.push(new L.LatLng(lat,lng));
          });
          var cycleline = L.polyline(cyclePoints, {color: 'blue'}).addTo(myMap);
        }
      });
    }
  });
};

$(function(){
  Map.initialize();
});
