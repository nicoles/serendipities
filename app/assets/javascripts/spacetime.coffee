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
  # containing a list of day storylines.
  drawDates: (data) =>
    return @ if not data.dates

    @dates = data.dates
    if @leaflet.hasLayer(@dayLayer)
      @dayLayer.clearLayers()
    @dayLayer = L.featureGroup()
    $.each data.dates, (index, date) => @drawDay(date)

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
      # 'snapEvents': false
      'style': 'dot'
      # TODO: Enable this for the 'blue bar' thing for the eventual animation
      # playback on the timeline.
      # 'showCustomTime': true
      'unselectable': false
      'selectable': false
      'eventMarginAxis': '-5px'
  }

  # (http://almende.github.io/chap-links-library/js/timeline/doc/)
  # Obtain a singleton event for the MOVES query.
  @TIME_RANGE: {
      'className': 'time-range'
      'start': null
      'end': null
      'content': 'moves query'
      'editable': true
      'dragAreaWidth': 30
      'animate': false
  }

  @DEFAULT_SELECTION: [{row: 0}]  # First element is the time-range query.

  constructor: ->
    @$start = $ 'input.start'  # Time input elements.
    @$end = $ 'input.end'      # The actual JSON requests are based on these.
    @$timeline = $('#timeline')[0]
    @timeline = new links.Timeline(@$timeline)
    @timeline.setCustomTime(new Date())
    @data = [];
    timeRange = TimeMachine.TIME_RANGE
    timeRange.start = str2date @$start.val()
    timeRange.end = str2date @$end.val()
    @data.push(timeRange)

    # Update form inputs to match timeline range.
    @on 'changed', () =>
      [start, end] = @getRange()
      @setDial(start, end)

    # Update timeline range when form inputs change. Also ensure start <= end
    # because we don't need time paradoxes.
    @$start.change =>
      start = str2date @$start.val()
      end = str2date @$end.val()
      if start > end
        start = end
        @$start.val(date2str start)
      @timeline.changeItem 0, { start: start }

    @$end.change =>
      start = str2date @$start.val()
      end = str2date @$end.val()
      if end < start
        end = start
        @$end.val(date2str end)
      @timeline.changeItem 0, { end: end }

  render: ->
    @refreshCache()
    @timeline.draw(@data, TimeMachine.TIMELINE_OPTIONS)
    @timeline.setSelection(TimeMachine.DEFAULT_SELECTION)

  # Returns a pair of Date objects describing the start and end dials on this
  # time machine.
  getRange: ->
    r = @timeline.getData(0)[0]
    [r.start, r.end]

  getJumpJSON: -> {
      start_date: @$start.val()
      end_date: @$end.val()
  }

  # Set the dials on this time machine.
  setDial: (start, end) ->
    if start > end  # No time paradoxes please.
      console.warn('start date tried to be beyond end date.')
      start = end
    @$start.val(date2str start)
    @$end.val(date2str end)

  refreshCache: ->
    console.log 'refreshing timeline cache blocks'
    fetchJSON('/cacheinfo')
      .then (data) -> dates = data.dates.sort()
      .then @setCached

  # Create a set of cache indicators on the timeline for each range of
  # contiguous dates.
  setCached: (dates) =>
    @_clearCacheBlocks()
    dates = $.map dates, str2date
    console.log dates
    first = dates[0]
    last = first
    for date in dates
      tmp = new Date(last)
      tmp.setDate(tmp.getDate() + 1)
      if date > tmp
        @_addCacheBlock(first, tmp)
        first = date
      last = date
    @_addCacheBlock(first, tmp)
    @timeline.redraw()
    @timeline.setSelection(TimeMachine.DEFAULT_SELECTION)

  _addCacheBlock: (first, last) ->
    console.log 'cached dates: ' + first + ' --> ' + last
    @timeline.addItem {
      className: 'cache-range'
      start: first
      end: last
      content: '⇩'
    }

  _clearCacheBlocks: =>
    total = @timeline.getData().length - 1
    console.log total
    # return if total < 1
    # $.map [1..total], (i, el)=> @timeline.deleteItem(el, true)

  # Attach an event listener for this timeline.
  # Valid events:
  #  http://almende.github.io/chap-links-library/js/timeline/doc/#Events
  on: (event, handler) ->
    links.events.addListener(@timeline, event, handler)


# Form's date input strictly requires YYYY-MM-DD
# Note:
#   This will break for years outside of 1000-9999 AD. Will fix once
#   immortality achieved.
date2str = (date) ->
  m = date.getMonth() + 1
  d = date.getDate()
  date.getFullYear() +
    (if m < 10 then '-0' else '-') + m +
    (if d < 10 then '-0' else '-') + d

str2date = (str) ->
  p = str.split('-')
  new Date(p[0], p[1]-1, p[2])


fetchJSON = (url, params=null) ->
  new Promise (F, R) ->
    request = $.getJSON url, params
    request.done F


# Entry point. Create new map, set event hooks, and render.
$ ->

  map = new Map('map')
  timeMachine = new TimeMachine('#timeline')
  # TODO: Use the 'custom time' bar as the animation feature.
  timeMachine.on 'timechange', () =>
    event.preventDefault()
    # console.log('timechange')
  timeMachine.on 'timechanged', () =>
    event.preventDefault()
    # console.log('timechanged')
  timeMachine.render()

  # AJAX request to db or moves API for current time machine's segment data.
  spaceTimeRequest = =>
    event.preventDefault()
    if str2date(timeMachine.$end.val()) > new Date()
      console.warn 'Cannot travel into the future yet.'
      return
    # Make request for all segments between |start_date| to |end_date|.
    fetchJSON '/mapdata', data=timeMachine.getJumpJSON()
      .then map.drawDates #(data) -> map.drawDates(data)
      # TODO: There's something weird here which is preventing the timeline
      # cache refresh from working. Fix later
      # .then timeMachine.refreshCache

  $('#map-date').submit (event) ->
    event.preventDefault()
    spaceTimeRequest()
    return false

  # TODO: Implement a toggle between auto-updating the map.
  timeMachine.on 'changed', spaceTimeRequest

# Auto-resize map when window changes size.
$(window).resize ->
  height = $(window).height()
  scale = 0.9
  $(".map").css('height', height * scale)
