(function($) {
    jQuery(document).ready(function() {
        const getCsrfHeaders = function() {
            let token = $('meta[name="csrf-token"]').attr('content')
            return {
                "Content-Type": "application/json",
                "X-CSRF-Token": token
            }
        }

        $('#tabbed').tabs();

        $('#user-table').tablesorter({
            theme: 'blue',
            widthFixed: true,
            widgets: ["zebra", "filter"],
            ignoreCase: true,
            filter_columnFilters: true,
            filter_saveFilters : true,
        });

        $('[data-toggle]').on('click', function(e) {
            let path = $(this).data('toggle')
            $.ajax({
                url: path,
                method: 'GET',
                headers: getCsrfHeaders()
            })
        })


        $('#select_all').on('change', function(e) {
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