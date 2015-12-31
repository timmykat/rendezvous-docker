// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('#register').on('click', function() {
    window.location.assign('/register');
  });
  $('#login').on('click', function() {
    window.location.assign('/sign_up_or_in');
  });
  
  if ($('.logged-in')) {
    var liHeight = $('.logged-in').height();
    $('.header-row').css({'marginTop': liHeight});
  }
});