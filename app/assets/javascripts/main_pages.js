// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('#register').on('click', function() {
    window.location.assign('/register');
  });
  $('#login').on('click', function() {
    window.location.assign('/sign_in');
  });
  
  var $b = $('body');
  $b.offset({top: 0});
  
  // Inquiry form validation
  $('.contact-form .form-input').keyup(function() {
    var email_regex = /^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[a-z][a-z])|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i;
    var passName = ($('.contact-form input#name').val().length >= 3);
    var passEmail = email_regex.test($('.contact-form input#email').val());
    var passMessage=  ($('.contact-form input#message').val().length >= 10);
    if (passName && passEmail && passMessage) {
      $('.contact-form .submit-btn').removeAttr('disabled');
    } else {
      $('.contact-form .submit-btn').attr('disabled','disabled');
    } 
  });
  
  // Fade out the flash wrapper when it appears
  $('.flash-wrapper').delay(5000).fadeOut();
  $('body').on('click', 'i.fa-close', function() {
    $('.flash-wrapper').hide();
  });
});