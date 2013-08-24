var mo = mo || {};

mo.map = function() {

    var leaflet,
        svg,
        g,
        segments = [],
        places = [],
        activities = [],
        dayLayer;

        leaflet = L.map('map');
        L.tileLayer.provider('Stamen.TonerLite').addTo(leaflet);
        svg = d3.select(leaflet.getPanes().overlayPane).append("svg"),
        g = svg.append("g").attr("class", "leaflet-zoom-hide");

    // Map.ActivityColors = {
    //     'wlk':'#ff00ff',
    //     'trp':'black',
    //     'cyc':'#00ffff',
    //     'run':'#ffff00'
    // };

// {"type":"FeatureCollection",
// "features":[{
//   "type":"Feature",
//   "geometry":{
//     "type":"MultiPolygon",
//     "coordinates":[[[[74.92,37.24],[74.57,37.0

    self.drawDay = function(day){
        if (!day.segments) return;

        segments = day.segments;
        if (leaflet.hasLayer(dayLayer)){
            dayLayer.clearLayers();
        }
        dayLayer = L.featureGroup();

        segments.forEach(function(segment){
            if (segment.place) self.addPlace(segment.place);
            if (segment.activities) self.addActivitiesSegment(segment);
        });

        dayLayer.addTo(leaflet);
        leaflet.fitBounds(dayLayer.getBounds());

        console.log(activities)
        // var bounds = d3.geo.bounds(collection),
        //     path = d3.geo.path().projection(project);

        // var feature = g.selectAll("path")
        //   .data(collection.features)
        // .enter().append("path");

        // map.on("viewreset", reset);
        // reset();

        function reset() {
            var bottomLeft = project(bounds[0]),
                topRight = project(bounds[1]);

            svg .attr("width", topRight[0] - bottomLeft[0])
                .attr("height", bottomLeft[1] - topRight[1])
                .style("margin-left", bottomLeft[0] + "px")
                .style("margin-top", topRight[1] + "px");

            g   .attr("transform", "translate(" + -bottomLeft[0] + "," + -topRight[1] + ")");

            feature.attr("d", path);
        }
        function project(x) {
            var point = map.latLngToLayerPoint(new L.LatLng(x[1], x[0]));
            return [point.x, point.y];
        }
    };

    self.addActivitiesSegment = function(segment){
        activities = activities.concat(segment.activities);
        segment.activities.forEach(function(activity){
            self.addActivity(activity);
        });
    };

    self.addActivity = function(activity){
        var trackPoints, color;

        trackPoints = activity.trackPoints.map(function(trackPoint){
            return new L.LatLng(trackPoint.lat,trackPoint.lon);
        });

        color = 'gray';
        L.polyline(trackPoints, {color: color}).addTo(dayLayer);
    };

    self.addPlace = function(place){
        if (place.name)
            L.marker([place.location.lat, place.location.lon],{title:place.name}).addTo(dayLayer);
        else
            L.circle([place.location.lat, place.location.lon],10).addTo(dayLayer);
    };

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
            self.drawDay(data);
        });
    });

    return self;
}();