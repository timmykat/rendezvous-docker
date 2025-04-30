import $ from 'jquery';

$(function(){
  $('#register').on('click', function() {
    window.location.assign('/register');
  });
  $('#login').on('click', function() {
    window.location.assign('/sign_in');
  });

  // Close registration model
  $('button.close-modal').on('click', function() {
    $('.registration-modal').hide();
  })

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
  // Let the user dismiss the flash
  // $('.flash-wrapper').delay(5000).fadeOut(400);
  $('.close-flash').on('click', function() {
    $(this).closest('.flash').fadeOut(200);
  });
});

