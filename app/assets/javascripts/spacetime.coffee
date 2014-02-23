###
Tie a leaflet map to a timeline using moves data.
###


# Describes a leaflet map with moves data.
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


# Encapsulates a simple timeline lib with customizations allowing arbitrary
# time-selections.
class TimeMachine

  @TIMELINE_OPTIONS: {
      'width': '100%'
      'zoomMin': 36000000  # Minimum is 1 hour (in ms)
      'snapEvents': false
      'style': 'dot'
      'showCustomTime': true
      'unselectable': false
  }

  @DEFAULT_SELECTION: [{row: 0}]  # First element is the time-range query.

  constructor: ->
    @start = 0
    @end = 0
    @data = [];
    @data.push(movesRange(2014, 0, 1))
    @$timeline = $('#timeline')[0]
    @timeline = new links.Timeline(@$timeline)
    @timeline.setCustomTime(new Date())

  render: ->
    @timeline.draw(@data, TimeMachine.TIMELINE_OPTIONS)
    @timeline.setSelection(TimeMachine.DEFAULT_SELECTION)

  # Returns a pair of Date objects describing the start and end dials on this
  # time machine.
  getRawRange: ->
    r = @timeline.getData(0)[0]
    [r.start, r.end]

  # Returns a pair of string-formatted dates.
  getRange: -> $.map @getRawRange(), (e,i) -> date2str(e)

  # Attach an event listener for this timeline.
  # Valid events:
  #  http://almende.github.io/chap-links-library/js/timeline/doc/#Events
  on: (event, handler) ->
    links.events.addListener(@timeline, event, () => handler(@))


# Form's date input strictly requires YYYY-MM-DD
# Note:
#   This will break for years outside of 1000-9999 AD. Will fix once
#   immortality achieved.
date2str = (date) ->
  m = date.getMonth() + 1
  d = date.getDate()
  '' + date.getFullYear() +
    (if m < 10 then '-0' else '-') + m +
    (if d < 10 then '-0' else '-') + d


# Entry point. Create new map, set event hooks, and render.
$ ->
  $start = $ 'input.start'  # Time input elements.
  $end = $ 'input.end'

  map = new Map('map')
  timeMachine = new TimeMachine('#timeline')
  timeMachine.on 'changed', () =>
    # Update form inputs to match timeline range.
    [start, end] = timeMachine.getRange()
    $start.val(start)
    $end.val(end)
  timeMachine.on 'timechange', () =>
    console.log('timechange')
  timeMachine.on 'timechanged', () =>
    console.log('timechanged')
  timeMachine.render()

  # Set-up AJAX handler.
  $('#map-date').submit (event) =>
    event.preventDefault()

    # Make request for all segments between |start_date| to |end_date|.
    request = $.getJSON '/mapdata', data={
      start_date: $start.val()
      end_date: $end.val()
    }
    request.done (data) ->
      map.drawDates(data)



# (http://almende.github.io/chap-links-library/js/timeline/doc/)

# Obtain a singleton event for the MOVES query.
movesRange = (year, month, day) =>
  {
    # 'className': 'moves-event',
    'start': new Date(year, month, day),
    'end': new Date(year, month+1, day),
    'content': 'moves query',
    'editable': true,
    'dragAreaWidth': 30,
    'animate': false
  }


# Auto-resize map when window changes size.
$(window).resize ->
  height = $(window).height()
  scale = 0.9
  $(".map").css('height', height * scale)
