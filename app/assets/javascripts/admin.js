$(function() {
  $('#tabbed').tabs();

  $('.admin_check').change(function(e) {
    let checked = false;
    let $user = $(this).parent().parent();
    let userId = $(this).attr('id').replace('is_admin_user_', '');
    let sendData = { user_id: userId }
    if ($(this).is(":checked")) {
      sendData.admin = 'admin';
      checked = true;
    } else {
      sendData.admin = false;
    }
    $.get('/ajax/toggle_admin', sendData, function() {
      if (checked) {
        $user.addClass('bg-success');
      } else {
        $user.removeClass('bg-success');
      }
    });
  });

  $('.tester_check').change(function(e) {
    let checked = false;
    let $user = $(this).parent().parent();
    let userId = $(this).attr('id').replace('is_tester_user_', '');
    let sendData = { user_id: userId }
    if ($(this).is(":checked")) {
      sendData.tester = 'tester';
      checked = true;
    } else {
      sendData.tester = false;
    }
    $.get('/ajax/toggle_tester', sendData, function() {
      if (checked) {
        $user.addClass('bg-info');
      } else {
        $user.removeClass('bg-info');
      }
    });
  });
});
