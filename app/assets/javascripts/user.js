$(function() {
  // Email confirmation
  var emailRegex =  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  $('.sign-up input[type=email]').on('keyup', function(e) {
    if ($(this).val().match(emailRegex)) {
      $(this).parent().addClass('has-feedback has-success');
    } else {
      $(this).parent().removeClass('has-feedback has-success');
    }
  });
  
  var passwordMatch = function() {
    var password = $('.sign-up #user_password').val();
    var password_confirmation = $('.sign-up #user_password_confirmation').val()
    return password == password_confirmation && $('.sign-up #user_password').parent().hasClass('has-success');
  }
    
  
  // Password validation & confirmation
  $('.sign-up input[type=password]').on('keyup', function(e) {
    var lower = $(this).val().match(/[a-z]/);  
    var upper = $(this).val().match(/[A-Z]/);  
    var digit = $(this).val().match(/[0-9]/);
    var length = $(this).val().length >= 8;

    if ($(this).hasClass('primary')) {
      if (lower) {
        $('i.pass.lower').addClass('success');
      } else {
        $('i.pass.lower').removeClass('success');
      } 
      if (upper) {
        $('i.pass.upper').addClass('success');
      } else {
        $('i.pass.upper').removeClass('success');
      } 
      if (digit) {
        $('i.pass.digit').addClass('success');
      } else {
        $('i.pass.digit').removeClass('success');
      }
      if (lower && upper && digit && length) {
        $(this).parent().addClass('has-feedback has-success');
      } else {
        $(this).parent().removeClass('has-feedback has-success');
      }
    } else if ($(this).hasClass('confirm')) {
      console.log('Hittin it');
      if (passwordMatch()) {
        $(this).parent().addClass('has-feedback has-success');
      } else {
        $(this).parent().removeClass('has-feedback has-success');
      }
    }
  });
});