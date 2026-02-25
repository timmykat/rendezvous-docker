import $ from 'jquery';

function adminFunctions() {

    const getCsrfHeaders = function() {
        let token = $('meta[name="csrf-token"]').attr('content')
        return {
            "Content-Type": "application/json",
            "X-CSRF-Token": token
        }
    }

    $('#user-table, #registration-table').tablesorter({
        theme: 'blue',
        widthFixed: true,
        widgets: ["zebra", "filter"],
        ignoreCase: true,
        filter_columnFilters: true,
        filter_saveFilters : true,
    });

    $('[data-nobs-toggle]').on('click', function() {
        const $el = $(this)
        const $checkbox = $el.find('input[type="checkbox"]')
        let path = $(this).data('nobs-toggle')
        $.ajax({
            url: path,
            method: 'GET',
            headers: getCsrfHeaders(),
            success: function() {
                $checkbox.toggle()
            }
        })
    })

    $('#select_all').on('change', function(e) {
        $('.delete_user').prop('checked', $(this).prop('checked'))
    })

    const $adminPanel = $('.admin_layout .manage')
    if (window.localStorage.getItem("adminPanelVis") === "hidden") {
        $adminPanel.hide()
    }

    $('.toggle_admin_panel').on('click', function(e) {
        if ($adminPanel.is(':visible')) {
            $adminPanel.hide()
            window.localStorage.setItem("adminPanelVis", "hidden")
        } else {
            $adminPanel.show()
            window.localStorage.setItem("adminPanelVis", "visible")
        }
    })
}

document.addEventListener('turbo:load', adminFunctions)
document.addEventListener('DOMContentLoaded', adminFunctions)
