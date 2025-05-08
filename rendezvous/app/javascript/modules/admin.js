import $ from 'jquery';

document.addEventListener('turbolinks:load', function(){
    console.log('Loading jquery')
    const getCsrfHeaders = function() {
        let token = $('meta[name="csrf-token"]').attr('content')
        return {
            "Content-Type": "application/json",
            "X-CSRF-Token": token
        }
    }

    console.log("Tablesorting users")
    $('#user-table').tablesorter({
        theme: 'blue',
        widthFixed: true,
        widgets: ["zebra", "filter"],
        ignoreCase: true,
        filter_columnFilters: true,
        filter_saveFilters : true,
    });

    $('[data-nobs-toggle]').on('click', function(e) {
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
})
