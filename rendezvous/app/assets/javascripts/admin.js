(function($) {
    jQuery(document).ready(function() {
        $('#tabbed').tabs();

        $('#user-table').tablesorter({
            widthFixed: true,
            widgets: ["zebra", "filter"],
            ignoreCase: true,
            headers: {
                '.address': {
                    sorter: false
                }
            }
        });

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

        $('button.delete_users').on('click', function() {
            let $checkedUsers = $('.delete_user:checked');
            let forDeletion = $.map($checkedUsers, function($check, index) {
                return $check.defaultValue;
            }).join(',');

            $.get('/ajax/delete_users', { "users": forDeletion }, function() {
                console.log('Success');
                window.location.assign('/admin');
            });
        });
    });
}) (jQuery);