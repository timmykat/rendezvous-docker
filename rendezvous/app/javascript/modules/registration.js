$(document).ready(function() {
  const registrationId = $('[data-registration_id]').data('registration_id');

  // 1. SET INDIVIDUAL FEE
  let setAttendeeFee = function(type, target) {
    let $card = $(target).closest('.card');
    // Safety check: default to 0 if the type isn't found in appData
    let fee = (appData.fees && appData.fees[type]) ? appData.fees[type] : 0;
    console.log('Setting fee data on attendee card')
    $card.data('fee', fee);
  };

  // 2. SUM ALL FEES
  let getAttendeeTotals = function() {
    console.log('Calculating fee total')
    let attendeeTotal = 0;
  
    // Sum data-fee from all visible attendee cards
    $('.card.attendee:visible').each(function() {
      let cardFee = parseFloat($(this).data('fee')) || 0;
      attendeeTotal += cardFee;
    });
  
    // Update registration fee input
    console.log('Setting attendee total')
    $('input#event_registration_registration_fee').val(attendeeTotal.toFixed(2));
  
    // Update counts for backend processing
    $('input#event_registration_number_of_adults').val($('#attendees input[value="adult"]:visible:checked').length);
    $('input#event_registration_number_of_youths').val($('#attendees input[value="youth"]:visible:checked').length);
    $('input#event_registration_number_of_children').val($('#attendees input[value="child"]:visible:checked').length);
  
    // Recalculate grand total (fee + donation)
    setTotal(); 
  };

  // 3. GRAND TOTAL (Fee + Donation)
  let setTotal = function() {
    console.log('Setting total')
    if (typeof appData !== 'undefined') {
      let regFee = parseFloat($('input#event_registration_registration_fee').val()) || 0;
      let donation = parseFloat($('input[name="event_registration[donation]"]').val()) || 0;

      let total = regFee + donation;
      $('input#event_registration_total').val(total.toFixed(2));

      // Async update DB
      const registrationId = $('[data-registration_id]').data('registration_id');
      $.post('/event/ajax/update_fees', { id: registrationId, donation: donation, total: total });
    }
  };

  // --- Initialization & Event Listeners ---

  // Handle first attendee UI logic
  let $firstAttendee = $('#attendees .nested-fields').first();
  $firstAttendee.find('.remove_association_action').remove();
  $firstAttendee.find('input[value="youth"], input[value="child"]').prop('disabled', true).parent().hide();
  $firstAttendee.find('.event_registration_attendees_name input').attr('placeholder', 'Your name *');

  // Populate first name if available
  if ($('input#event_registration_user_attributes_last_name').length > 0) {
    let fullName = `${$('input#event_registration_user_attributes_first_name').val()} ${$('input#event_registration_user_attributes_last_name').val()}`;
    $firstAttendee.find('input[placeholder="Your name *"]').val(fullName);
  }

  // Initial calculation
  getAttendeeTotals();

  // Radio button changes
  $('#attendees').on('change', 'input[type=radio]', function(e) {
    setAttendeeFee(this.value, this);
    getAttendeeTotals(); 
  });

  // Cocoon Hooks
  $('#attendees').on('cocoon:after-insert', function(e, insertedItem) {
    console.log('Cocoon insert')
    let $radio = $(insertedItem).find('input[type=radio]:checked');
    setAttendeeFee($radio.val(), $radio);
    getAttendeeTotals();
  });

  $('#attendees').on('cocoon:after-remove',function() {
    console.log('Cocoon insert')
    getAttendeeTotals();
  });

  // Donation logic
  $('.total-calculation').on('click blur change', function() {
    let $this = $(this);
    if ($this.is(':radio')) {
      let val = $this.val() === 'other' ? 0 : parseFloat($this.val());
      $('input#event_registration_donation').val(val.toFixed(2));
    }
    setTotal();
  });

  // Payment Method Switching
  const showPaymentMethod = function(value) {
    const isOnline = (value === 'credit card');
    $('#payment-online, #payment-paid').toggle(isOnline);
    $('#payment-cash').toggle(!isOnline);
    
    $.get('/event/ajax/update_paid_method', { id: registrationId, paid_method: value });
  };

  $('input.payment-method').on('change', function() {
    showPaymentMethod($(this).val());
  });

  // Form Submission safety
  $('form').on('submit', function() {
    $('input.calculated, input[type=email]').prop('disabled', false);
    $('.review-loader').show();
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
