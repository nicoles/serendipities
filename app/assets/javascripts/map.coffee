###
Render MOVES segments / activities onto a Leaflet map.
###

class Map
  constructor: (@$id) ->
    @leaflet = L.map(@$id)
        .setView([10, 0], 3)  # Default whole-world view.
    @tiles = L.tileLayer.provider('Stamen.TonerLite')
    @tiles.addTo(@leaflet)
    @dates = []
    @segments = []
    @activities = []
    @dayLayer = null

  # Render segments for one individual |day|.
  drawDay: (day) ->
    day = $.parseJSON(day)
    return @ if not day.segments
    @segments = day.segments
    @segments.forEach (segment) =>
      @addPlaceSegment(segment) if segment.place
      @addActivitiesSegment(segment) if segment.activities

    @dayLayer.addTo(@leaflet)
    @leaflet.fitBounds(@dayLayer.getBounds())

  # Draw all the days within data, which is expected to be a JSON object
  # containing a list of dates.
  drawDates: (data) ->
    return @ if not data.dates

    @dates = data.dates
    if @leaflet.hasLayer(@dayLayer)
      @dayLayer.clearLayers()
    @dayLayer = L.featureGroup()
    $.each data.dates, (index, date) =>
      @drawDay(date)

  # TODO
  addPlaceSegment: (segment) ->

  addActivitiesSegment: (segment) ->
    @activities = @activities.concat(segment.activities)
    segment.activities.forEach (activity) => @addActivity(activity)

  @ACTIVITY_COLORS: {
    'wlk': 'green'
    'trp': 'black'
    'cyc': 'blue'
    'run': 'red'
  }

  addActivity: (activity) ->
    # Map trackpoints to LatLng.
    trackPoints = activity.trackPoints.map (pt) => new L.LatLng(pt.lat, pt.lon)
    color = Map.ACTIVITY_COLORS[activity.activity] || 'gray'
    L.polyline(trackPoints, { color: color }).addTo(@dayLayer)


# Entry point. Create new map, set event hooks, and render.
$ ->
  map = new Map('map')

  $start = $ 'input.start'
  $end = $ 'input.end'

  $('#map-date').submit (event) =>
    event.preventDefault()

    # Make request for all segments between |start_date| to |end_date|.
    request = $.getJSON '/mapdata', data={
      start_date: $start.val()
      end_date: $end.val()
    }
    request.done (data) ->
      map.drawDates(data)


# Auto-resize map when window changes size.
$(window).resize ->
  height = $(window).height()
  scale = 0.9
  $(".map").css('height', height * scale)

