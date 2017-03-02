$(document).ready(function() {
    $('#current_source_substance td.y_n').each(function () {
        if ($(this).text() == 'Not Available') {
            $(this).closest('tr').css('background-color', '#ffe6e6');
        }
    });
});
