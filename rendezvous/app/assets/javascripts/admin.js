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

        $('[data-toggle]').on('click', function(e) {
            let path = '/ajax/toggle/' + $(this).data('toggle')
            console.log(path)
            $.get(path)
        })


        $('#select_all').on('change', function(e) {
            console.log('Changed')
            $('.delete_user').prop('checked', $(this).prop('checked'))
        })

        $('.toggle_admin_bar').on('click', function() {
            $('header .manage').toggle()
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