$(function() {
    $('#tabbed').tabs();

    $('#user-table').tablesorter();

    $('.admin_check').on('change', function(e) {
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

    $('.tester_check').on('change', function(e) {
        console.log("Tester checkbox change");
        let checked = false;
        let $user = $(this).parent().parent();
        let userId = $(this).attr('id').replace('is_tester_user_', '');
        let sendData = { user_id: userId }
        if ($(this).is(":checked")) {
            console.log("Adding tester")
            sendData.tester = 'tester';
            checked = true;
        } else {
            console.log("Removing tester")
            sendData.tester = false;
        }
        console.log("Sending data", sendData);
        $.get('/ajax/toggle_tester', sendData, function() {
            console.log("Test request submitted");
            if (checked) {
                $user.addClass('bg-info');
            } else {
                $user.removeClass('bg-info');
            }
        });
    });

    $('button.delete_users').on('click', function() {
        console.log("Clicked delete")
        let $checkedUsers = $('.delete_user:checked');
        let forDeletion = $.map($checkedUsers, function($check, index) {
            return $check.defaultValue;
        }).join(',');

        console.log(forDeletion);
        $.get('/ajax/delete_users', { "users": forDeletion }, function() {
            console.log('Success');
            window.location.assign('/admin');
        });
    });
});