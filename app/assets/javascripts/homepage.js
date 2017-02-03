// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$.fn.exists = function () {
    return this.length !== 0;
}

$(function(){
  window.setupExploreMap();
  window.setupJournalMap();
});
