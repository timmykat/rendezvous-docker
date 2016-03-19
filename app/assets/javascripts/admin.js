$(function() {
  $('#tabbed').tabs();
  
  $('.admin_check').on('click', function(e) {
    var $user = $(this).parent().parent();
    var $admin = $(this).prop('checked');
    var userId = $(this).attr('id').replace('is_admin_user_', '');
    $.get('/ajax/toggle_admin', { user_id: userId, admin: $admin }, function() {
      if ($admin) {
        $user.addClass('bg-success');
      } else {
        $user.removeClass('bg-success');
      }
    });
  }); 
});