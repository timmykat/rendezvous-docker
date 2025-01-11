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

        $('[type=checkbox].user_test').on('change', function(e) {
  
            let $checkbox = $(this)
            let user_id = $checkbox.attr('name')
            $.get('/ajax/toggle_user_testing', {user_id: user_id}, (data) => {
                console.log(data)
                $checkbox.prop('checked', data.status)
            })
        })

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

        $('#select_all').on('change', function(e) {
            console.log('Changed')
            $('.delete_user').prop('checked', $(this).prop('checked'))
        })

        // $('button#delete_users').on('click', function() {
        //     let $checkedUsers = $('.delete_user:checked');
        //     let forDeletion = $.map($checkedUsers, function($check, index) {
        //         return $check.defaultValue;
        //     }).join(',');

        //     $.get('/ajax/delete_users', { "users": forDeletion }, function() {
        //         console.log('Success');
        //         window.location.assign('/admin');
        //     });
        // });
    });
}) (jQuery);