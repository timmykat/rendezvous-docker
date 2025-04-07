// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// Number.prototype.currency = function(c, d, t){
// var n = this, 
//     c = isNaN(c = Math.abs(c)) ? 2 : c, 
//     d = d == undefined ? "." : d, 
//     t = t == undefined ? "," : t, 
//     s = n < 0 ? "-" : "", 
//     i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))), 
//     j = (j = i.length) > 3 ? j % 3 : 0;
//    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
// };

(function($) {
  jQuery(document).ready(function() {
    const registrationId = $('[data-registration_id]').data('registration_id')
    
    var setRegistrationFee = function() {
      if (typeof appData != 'undefined') {
        var total = $('input#event_registration_number_of_adults').val() * appData.event_fee;
          // + $('input#event_registration_number_of_children').val() * appData.fees.child;  # Registration for kids is free
        $('input#event_registration_registration_fee').val((total).toFixed(2));
      }
    };
    var getAttendeeTotals = function() {
      var adults = $('#attendees input[value="adult"]:visible:checked').length;
      $('input#event_registration_number_of_adults').val(adults); 
      var children = $('#attendees input[value="child"]:visible:checked').length;
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
      var firstName = $('input#event_registration_user_attributes_first_name').val();
      var lastName = $('input#event_registration_user_attributes_last_name').val();
      $('#attendees input[placeholder="Your name *"]:first').val(firstName + ' ' + lastName);
    }
    

    // Get adult and kid totals
    $('#attendees').on('click', 'input[type=radio]', function(e) { 
      getAttendeeTotals(); 
    });
    $('#attendees').on('cocoon:after-insert cocoon:after-remove', function(e) {
      getAttendeeTotals();
    });
    

    // Update registration fee
    $('.fee-calculation').on('change click keyup', function(e) {
      setRegistrationFee();  
    });
    
    // Get final total on payment page
    var setTotal = function() {
      if (typeof appData != 'undefined') {
        var donation = $('input[name="event_registration[donation]"]:checked').val();
        if (donation == 'other') {
          donation = $('input[name="event_registration[donation]"][type=number]').val();
        }

        var vendorFee = $('input[name="event_registration[vendor_fee]"]').val()

        if ($.isNumeric(donation)) {
          donation = parseFloat(donation);
        } else {
          donation = 0.
        }
        var total = parseFloat(appData.event_registration_fee) + donation + parseFloat(vendorFee);
        $('input#event_registration_total').val(total.toFixed(2));

        // Update donation and total in the DB
        console.log(registrationId, donation, total)
        $.post('/event/ajax/update_fees', { id: registrationId, donation: donation, total: total})
      }
    };
    
    // Update total
    $(document).on('load', setTotal)
    $('.total-calculation').on('click blur', function(e) {
      setTotal();
    });

    // Toggle access to donation other amount field
    $('input[type=radio].total-calculation').on('click', function(e) {
      if ($(this).val() == 'other') {
        $('input#event_registration_donation').attr('disabled', false);
      } else {
        $('input#event_registration_donation').attr('disabled', true).val('');
      }
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
      $.get('/event/ajax/update_paid_method', { id: registrationId, paid_method: value})
    }
    
    // Set payment method
    $('input.payment-method:checked').each(function() {
        showChecked($(this).val())
    })

    $('input.payment-method').on('click', function() {
      showChecked($(this).val())
    });  

    // Spinner
    $('.go-to-payment').click(function(e) {
      $('.review-loader').show();
    })
  });
}) (jQuery);