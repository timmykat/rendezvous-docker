function adminFunctions() {
    $.ajaxSetup({
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        }
    });

    // --- 1. SimpleMDE Logic ---
    function adjustEditorHeight(editor) {
        var cm = editor.codemirror;
        var scrollHeight = cm.getScrollInfo().height;
        cm.getWrapperElement().style.height = Math.max(150, scrollHeight) + "px";
    }

    const textareas = document.querySelectorAll('textarea[id$="_simple_mde"]');
    textareas.forEach((textarea) => {
        if (!textarea.dataset.mdeInitialized) {
            const simpleMDE = new SimpleMDE({
                element: textarea,
                spellChecker: false,
                autosave: { enabled: false } 
            });
            simpleMDE.codemirror.on("change", () => adjustEditorHeight(simpleMDE));
            adjustEditorHeight(simpleMDE);
            textarea.dataset.mdeInitialized = "true";
        }
    });

    // --- 2. Tablesorter ---
    // Destroy previous instance if it exists to prevent 'ghost' headers
    $('#user-table, #registration-table').trigger("destroy"); 
    $('#user-table, #registration-table').tablesorter({
        theme: 'blue',
        widthFixed: true,
        widgets: ["zebra", "filter"],
        ignoreCase: true,
        filter_columnFilters: true,
        filter_saveFilters : true,
    });

    // --- 3. Event Listeners (Using .off() to prevent double-binding) ---
    $('[data-nobs-toggle]').off('click').on('click', function() {
        const $el = $(this);
        const $checkbox = $el.find('input[type="checkbox"]');
        let path = $el.data('nobs-toggle');
        
        $.ajax({
            url: path,
            method: 'GET',
            headers: { "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content') },
            success: function() {
                // Better than .toggle(): explicitly set the property
                $checkbox.prop('checked', !$checkbox.prop('checked'));
            }
        });
    });

    $('#select_all').off('change').on('change', function(e) {
        $('.delete_user').prop('checked', $(this).prop('checked'));
    });

    // --- 4. Admin Panel Visibility ---
    const $adminPanel = $('.admin_layout .manage');
    if (window.localStorage.getItem("adminPanelVis") === "hidden") {
        $adminPanel.hide();
    }

    $('.toggle_admin_panel').off('click').on('click', function(e) {
        if ($adminPanel.is(':visible')) {
            $adminPanel.hide();
            window.localStorage.setItem("adminPanelVis", "hidden");
        } else {
            $adminPanel.show();
            window.localStorage.setItem("adminPanelVis", "visible");
        }
    });
}

// ONLY use turbo:load to avoid double-firing on initial page load
document.addEventListener('turbo:load', adminFunctions);