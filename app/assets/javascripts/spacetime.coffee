###
  Render and hook up timeline to moves.
###

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


$ () ->
  data = [];
  data.push(movesRange(2014, 0, 1));

  # Tweaking the timeline interaction to make sense with moves.
  options = {
    'width': '100%',
    'zoomMin': 36000000,  # Minimum is 1 hour (in ms)
    'snapEvents': false,
    'style': 'dot',
    'showCustomTime': true,
    'unselectable': false
  };
  $timeline = $('#timeline')[0];

  onEvent = (event, handler) =>
    links.events.addListener(timeline, event, handler);

  # Assumes timeline-min.js has been loaded, and the global var |timeline| is
  # already the correct DOM element.
  # (http://almende.github.io/chap-links-library/js/timeline/doc/)
  timeline = new links.Timeline($timeline);
  timeline.setCustomTime(new Date());

  # links.events.addListener(timeline, 'select', function() {
    # var sel = timeline.getSelection();
    # console.log(sel);
  # })
  defaultSelection = [{row: 0}];  # First element is the MOVES query.

  # Render everything.
  timeline.draw(data, options);
  timeline.setSelection(defaultSelection);
