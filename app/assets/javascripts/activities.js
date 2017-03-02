$( document).ready(function () {
    $('.collapse').on('shown.bs.collapse', function () {
        $(this).parent().find(".fa-arrow-circle-down").removeClass("fa-arrow-circle-down").addClass("fa-arrow-circle-up");
    }).on('hidden.bs.collapse', function () {
        $(this).parent().find(".fa-arrow-circle-up").removeClass("fa-arrow-circle-up").addClass("fa-arrow-circle-down");
    });
});
