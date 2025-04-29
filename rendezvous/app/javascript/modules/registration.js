import $ from 'jquery'

$(document).ready(function() {
  const registrationId = $('[data-registration_id]').data('registration_id')

  let setPaymentSpinner = () => {
    $('.btn-square-pay').on('click', () => {
      let spinnerHtml = '<div class="spinner-grow text-primary" role="status"></div>'
      $(this).html("Connecting" + spinnerHtml)
    })
  }
  
  let setRegistrationFee = () => {
    if (typeof appData != 'undefined') {
      let total = $('input#event_registration_number_of_adults').val() * appData.event_fee;
        // + $('input#event_registration_number_of_children').val() * appData.fees.child;  # Registration for kids is free
      $('input#event_registration_registration_fee').val((total).toFixed(2));
    }
  };
  let getAttendeeTotals = () => {
    let adults = $('#attendees input[value="adult"]:visible:checked').length;
    $('input#event_registration_number_of_adults').val(adults); 
    let children = $('#attendees input[value="child"]:visible:checked').length;
    $('input#event_registration_number_of_children').val(children);  
    setRegistrationFee();  
  }
      
  // Remove the remove button from the first attendee and lock and hide the child selection
  $('#attendees .remove_association_action:first').remove();
  $('#attendees input[value="child"]:first').attr('disabled', true);
  $('#attendees input[value="child"]:first').parent().hide();
  $('#attendees .event_registration_attendees_name input:first').attr('placeholder', 'Your name *');
  
  // Initialize - set the first attendee info and get totals
  // $('#attendees input[value="adult"]:first').attr('checked', 'checked');
  getAttendeeTotals(); 
  
  if ($('input#event_registration_user_attributes_last_name').length > 0) {
    let firstName = $('input#event_registration_user_attributes_first_name').val();
    let lastName = $('input#event_registration_user_attributes_last_name').val();
    $('#attendees input[placeholder="Your name *"]:first').val(firstName + ' ' + lastName);
  }
  

  // Get adult and kid totals
  $('#attendees').on('click', 'input[type=radio]', (e) => { 
    getAttendeeTotals(); 
  });
  $('#attendees').on('cocoon:after-insert cocoon:after-remove', (e) => {
    getAttendeeTotals();
  });
  

  // Update registration fee
  $('.fee-calculation').on('change click keyup', (e) => {
    setRegistrationFee();  
  });
  
  // Get final total on payment page
  let setTotal = () => {
    if (typeof appData != 'undefined') {
      let donation = $('input[name="event_registration[donation]"]').val()
      console.log('Donation', donation)

      let vendorFee = $('input[name="event_registration[vendor_fee]"]').val() || 0.0
      vendorFee = parseFloat(vendorFee)

      if ($.isNumeric(donation)) {
        console.log('Is numeric')
        donation = parseFloat(donation);
      } else {
        donation = 0.
      }
      let total = parseFloat(appData.event_registration_fee) + donation + parseFloat(vendorFee);
      console.log('Total')
      $('input#event_registration_total').val(total.toFixed(2));

      // Update donation and total in the DB
      const registrationId = $('[data-registration_id]').data('registration_id')
      $.post('/event/ajax/update_fees', { id: registrationId, donation: donation, total: total})
    }
  };

  
  // Update total
  $(document).on('load', setTotal)
  $('.total-calculation').on('click blur', (e) => {
    setTotal();
  });

  // Toggle access to donation other amount field
  $('input[type=radio].total-calculation').on('click', (e) => {
    let val = $(this).val()
    if (val == 'other') {
      $('input#event_registration_donation').val(parseFloat(0.0).toFixed(2))
    } else {
      val = parseFloat(val).toFixed(2)
      $('input#event_registration_donation').val(val);
    }
    setTotal()
  });
  
  
  // Enable the email, amount and adult- and child-count fields upon form submission
  $('form').bind('submit', () => {
    $('input.calculated, input[type=email]').prop('disabled', false);
  });

  const showChecked = (value) => {
    if (value == 'credit card') {
      $('#payment-online').show();
      $('#payment-cash').hide();
      $('#payment-paid').show()
    } else {
      $('#payment-online').hide();
      $('#payment-cash').show();
      $('#payment-paid').hide()        
    }
    const registrationId = $('[data-registration_id]').data('registration_id')
    $.get('/event/ajax/update_paid_method', { id: registrationId, paid_method: value})
  }
  
  // Set payment method
  $('input.payment-method:checked').each(() => {
      showChecked($(this).val())
  })

  $('input.payment-method').on('click', () => {
    showChecked($(this).val())
  });  

  // Spinner
  setPaymentSpinner()
});
