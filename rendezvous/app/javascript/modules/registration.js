import $ from 'jquery'

$(function(){
  const registrationId = $('[data-registration_id]').data('registration_id')
  const CSRF_TOKEN = $('meta[name="csrf-token"]').attr('content')

  let setPaymentSpinner = function() {
    $('.btn-square-pay').on('click', function() {
      let spinnerHtml = '<div class="spinner-grow text-primary" role="status"></div>'
      $(this).html("Connecting...").after(spinnerHtml).removeClass('btn-square-pay')
    })
  }
  
  let setRegistrationFee = function() {
    if (typeof appData != 'undefined') {
      let total = $('input#event_registration_number_of_adults').val() * appData.event_fee;
        // + $('input#event_registration_number_of_children').val() * appData.fees.child;  # Registration for kids is free
      $('input#event_registration_registration_fee').val((total).toFixed(2));
    }
  };
  let getAttendeeTotals = function() {
    if (!$('#attendees')) return
    let adults = $('#attendees input[value="adult"]:visible:checked').length;
    console.log('Adults', adults)
    $('input#event_registration_number_of_adults').val(adults); 
    let children = $('#attendees input[value="child"]:visible:checked').length;
    console.log('Children', children)
    $('input#event_registration_number_of_children').val(children);  
    setRegistrationFee();  
  }
      
  // Remove the remove button from the first attendee and lock and hide the child selection
  $('#attendees').find('.remove_association_action').first().remove();
  $('#attendees').find('input[value="child"]').first().attr('disabled', true);
  $('#attendees').find('input[value="child"]').first().parent().hide();
  $('#attendees').find('.event_registration_attendees_name input').first().attr('placeholder', 'Your name *');
  
  // Initialize - set the first attendee info and get totals
  // $('#attendees input[value="adult"]:first').attr('checked', 'checked');
  getAttendeeTotals(); 
  
  if ($('input#event_registration_user_attributes_last_name').length > 0) {
    let firstName = $('input#event_registration_user_attributes_first_name').val();
    let lastName = $('input#event_registration_user_attributes_last_name').val();
    console.log('Setting reg name', firstName + ' ' + lastName)
    $('#attendees input[placeholder="Your name *"]:first').val(firstName + ' ' + lastName);
  }
  

  // Get adult and kid totals
  $('#attendees').on('click', 'input[type=radio]', function() { 
    getAttendeeTotals(); 
  });

  $(document).on('cocoon:after-insert cocoon:after-remove', function(e, insertedItem) {
    console.log('Cocoon fired on ', e.target)
    getAttendeeTotals();
  });

  // Update registration fee
  $('.fee-calculation').on('change click keyup', function() {
    setRegistrationFee();  
  });
  
  // Get final total on payment page
  let setTotal = function() {
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
      $.ajax({
        url: '/event/ajax/update_fees', 
        method: 'POST',
        data: { id: registrationId, donation: donation, total: total},
        headers: {
          "X-CSRF-Token": CSRF_TOKEN
        }
      })
    }
  };

  
  // Update total
  $(document).on('load', setTotal)
  $('.total-calculation').on('click blur', function() {
    console.log('Setting total')
    setTotal();
  });

  // Toggle access to donation other amount field
  $('input[type=radio].total-calculation').on('click', function() {
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
  $('form').bind('submit', function() {
    $('input.calculated, input[type=email]').prop('disabled', false);
  });

  const showChecked = function(value) {
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
    $.get({
      url: '/event/ajax/update_paid_method', 
      method: 'GET',
      data: { id: registrationId, paid_method: value},
      headers: {
        "X-CSRF-Token": CSRF_TOKEN
      }
    })
  }
  
  // Set payment method
  $('input.payment-method:checked').each(function() {
      showChecked($(this).val())
  })

  $('input.payment-method').on('click', function() {
    showChecked($(this).val())
  });  

  // Spinner
  setPaymentSpinner()
});
