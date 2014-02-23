/*
  Render and hook up timeline to moves.
*/
var data = [];
function push(year, month, day, label) {
  data.push({
    'start': new Date(year, month, day),
    'content': label
  });
}

var options = {
  height: '88px',
  'width': '100%',
  'editable': true
};

$(function() {

  push(2012, 0, 1, 'lol');
  push(2013, 0, 1, 'wat');

  var $timeline = $('#timeline')[0];

  // Assumes timeline-min.js has been loaded, and the global var |timeline| is
  // already the correct DOM element.
  // (http://almende.github.io/chap-links-library/js/timeline/doc/)
  var timeline = new links.Timeline($timeline);

  timeline.draw(data, options);
}); 
