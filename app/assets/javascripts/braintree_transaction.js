$(function() {

  var set_total = function() {
    var total = $('select#rendezvous_registration_number_of_adults').val() * appData.fees.registration.adult
       + $('select#rendezvous_registration_number_of_children').val() * appData.fees.registration.child;
    $('input#rendezvous_registration_amount').val(total);  
  };
  
  set_total();

  // Calculate registration fee
  $('#new_rendezvous_registration select').on('change', function(e) {
    set_total();  
  });
  
  // Enable the amount field upon form submission
  $('form').bind('submit', function() {
    $('input#rendezvous_registration_amount').prop('disabled', false);
  });
});