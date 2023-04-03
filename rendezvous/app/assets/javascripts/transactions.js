$(function() {
  $('#transaction_transaction_method').on('change', function(e) {
    if (e.target.value == 'credit card') {
      $('#transaction_cc_transaction_id').attr('disabled', false);
    } else {
       $('#transaction_cc_transaction_id').attr('disabled', true);
    }
  });
});