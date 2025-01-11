(function($) {
  jQuery(document).ready(function() {
    const eventId = window.location.href.match(/\d+/)[0]
    $('#event_registration_paid_method_credit_card').on('click', function() {
      console.log('Credit card clicked')
      $.get("/ajax/update_paid_method", {"id": eventId, "paid_method": "credit card"}, (data) => {
        console.log(data)
      })
    })
    $('#event_registration_paid_method_cash_or_check').on('click', function() {
      console.log('Cash or check clicked')
      $.get("/ajax/update_paid_method", {"id": eventId, "paid_method": "cash or check"}, (data) => {
        console.log(data)
      })
    })
  })
}) (jQuery)
