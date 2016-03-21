// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  var setRegistrationFee = function() {
    if (typeof appData != 'undefined') {
      var total = $('input#rendezvous_registration_number_of_adults').val() * appData.fees.registration.adult
         + $('input#rendezvous_registration_number_of_children').val() * appData.fees.registration.child;
      $('input#rendezvous_registration_registration_fee').val(total);
    }
  };
      
  // Remove the remove button from the first attendee and lock the child selection
  $('#attendees a.remove_fields:first').remove();
  $('#attendees input[value="child"]:first').attr('disabled', true);
  $('#attendees .rendezvous_registration_attendees_name input:first').attr('placeholder', 'Your name *');
  
  // Initialize - set the first attendee info and get totals
  $('#attendees input[value="adult"]:first').attr('checked', 'checked');
  $('input#rendezvous_registration_number_of_adults').val(1);
  $('input#rendezvous_registration_number_of_children').val(0);
  setRegistrationFee();
  
  $('input#rendezvous_registration_user_attributes_first_name, input#rendezvous_registration_user_attributes_last_name').on('blur', function(e) {
    var firstName = $('input#rendezvous_registration_user_attributes_first_name').val();
    var lastName = $('input#rendezvous_registration_user_attributes_last_name').val();
    $('#attendees input[placeholder="Your name *"]:first').val(firstName + ' ' + lastName);
  });
  

  // Get adult and kid totals
  $('#attendees').on('click', 'input[type=radio], i.fa-minus', function(e) {  
    var adult = $('#attendees input[value="adult"]:checked').length;
    $('input#rendezvous_registration_number_of_adults').val(adult);  
    var child = $('#attendees input[value="child"]:checked').length;
    $('input#rendezvous_registration_number_of_children').val(child);  
    setRegistrationFee();  
  });
  

  // Update registration fee
  $('.fee-calculation').on('change click keyup', function(e) {
    setRegistrationFee();  
  });
  
  // Get final total on payment page
  var setTotal = function() {
    if (typeof appData != 'undefined') {
      var donation = $('input[name="rendezvous_registration[donation]"]:checked').val();
      if (donation == 'other') {
        donation = $('input[name="rendezvous_registration[donation]"][type=number]').val();
      }
      if ($.isNumeric(donation)) {
        donation = parseFloat(donation);
      } else {
        donation = 0.
      }
      $('input#rendezvous_registration_total').val(appData.total + donation);
    }
  };
  
  // Update total
  $('.total-calculation').on('click keyup', function(e) {
    setTotal();
  });

  // Toggle access to donation other amount field
  $('input[type=radio].total-calculation').on('click', function(e) {
    if ($(this).val() == 'other') {
      $('input#rendezvous_registration_donation').attr('disabled', false);
    } else {
      $('input#rendezvous_registration_donation').attr('disabled', true).val('');
    }
  });
  
  
  // Enable the email, amount and adult- and child-count fields upon form submission
  $('form').bind('submit', function() {
    $('input.calculated, input[type=email]').prop('disabled', false);
  });
  
  // Toggle CC vs mailing address
  $('input.payment').on('click', function() {
    $('#payment-form').toggleClass('hidden');
    $('#mailing-address').toggleClass('hidden');
  });  
});