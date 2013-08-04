Map = {};

Map.initialize = function(){
  this.map = L.map('map').setView([37.775, -122.418], 13);
  L.tileLayer.provider('Stamen.Toner').addTo(this.map);
};


$(function(){
  Map.initialize();
});
