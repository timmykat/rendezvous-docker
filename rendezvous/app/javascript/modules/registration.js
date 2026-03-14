import $ from 'jquery'

document.addEventListener('turbo:load',  function(){
  if ($('special-events').length > 0) return
  let regId = $('[data-registration_id]').data('registration_id')
  let csrfToken = $('meta[name="csrf-token"]')?.attr('content')
  console.log(regId)
  console.log(csrfToken)

  let setPaymentSpinner = function() {
    $('.btn-square-pay').on('click', function() {
      let spinnerHtml = '<div class="spinner-grow text-primary" role="status"></div>'
      $(this).html("Connecting...").after(spinnerHtml).removeClass('btn-square-pay')
    })
  }

  // 1. SET INDIVIDUAL FEE
  let setAttendeeFee = function(type, target) {
    console.log('Setting attendee fee', type, target)
    let $card = $(target).closest('.card');
    // Safety check: default to 0 if the type isn't found in appData
    let fee = (appData.fees && appData.fees[type]) ? appData.fees[type] : 0;
    console.log('Fee:', fee)
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
    // 1. Don't run if the page is literally changing
    if (document.documentElement.hasAttribute("data-turbo-visit_control")) return;

    const idElement = document.querySelector('[data-registration_id]');
    if (!idElement) return; // 2. Don't run if we aren't on a registration page

    let regId = idElement.dataset.registration_id;
    console.log('Setting total for ', regId)
    if (typeof appData !== 'undefined') {
      let regFee = parseFloat($('input#event_registration_registration_fee').val()) || parseFloat(appData.event_registration_fee);
      let donation = parseFloat($('input[name="event_registration[donation]"]').val()) || 0;
      let total = regFee + donation;

      console.log('Reg fee:', regFee)
      console.log('Donation:', donation)
      console.log('Total:', total)

      if (!regFee || !total) return;

      $('input#event_registration_total').val(total.toFixed(2));

      const requestBody = JSON.stringify({ 
        id: regId, 
        donation: donation, 
        total: total 
      })

      console.log('requestBody', requestBody)

      fetch('/event/ajax/update_fees', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: requestBody
      })
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok');
        return response.json();
      })
      .then(data => console.log('Update successful:', data))
      .catch(error => console.error('Error updating fees:', error));
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
  $(document).on('change', '#attendees input[type=radio]', function(e) {
    setAttendeeFee(this.value, this);
    getAttendeeTotals(); 
  });

  // Cocoon Hooks
  $('#attendees').on('cocoon:after-insert', function(e, insertedItem) {
    let $radio = $(insertedItem).find('input[type=radio]:checked');
    setAttendeeFee($radio.val(), $radio);
    getAttendeeTotals();
  });

  $('#attendees').on('cocoon:after-remove',function() {
    getAttendeeTotals();
  });

  // Donation logic
  $(document).on('click blur change', '.total-calculation', function() {
    let $this = $(this);
    if ($this.is(':radio')) {
      let val = $this.val() === 'other' ? 0 : parseFloat($this.val());
      $('input#event_registration_donation').val(val.toFixed(2));
    }
    setTotal();
  });

  // Payment Method Switching
  const showPaymentMethod = function(value) {
    console.log('Method value', value)
    const isOnline = (value === 'credit card');
    console.log('isOnline', isOnline)
    $('#payment-online, #payment-paid').toggle(isOnline);
    $('#payment-cash').toggle(!isOnline);
    
    $.get('/event/ajax/update_paid_method', { id: regId, paid_method: value });
  };

  $(document).on('change', 'input.payment-method', function() {
    console.log('Payment method changed:', $(this).val());
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
    const regId = $('[data-registration_id]').data('registration_id')
    $.get({
      url: '/event/ajax/update_paid_method', 
      method: 'GET',
      data: { id: regId, paid_method: value},
      headers: {
        "X-CSRF-Token": csrfToken
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
