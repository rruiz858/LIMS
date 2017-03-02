// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require pnotify.custom.min.js
//= require_tree .



$( document).ready(function () {
    $('.submitButton').click(function () {
        $('body').addClass('loading');
    });
    $(function () {
        $('[data-toggle="popover"]').popover(
            {container: 'body'}
        )
    });
    $('table.defaultTable').DataTable({
    });
});




$( document).ready(function() {
    $body = $("body");
    $(window).unload(function () {
        setTimeout(function () {
            $body.removeClass('loading');
        }, 2000);

    });
    $('.upload_file_form').submit(function () {
        $body.addClass("loading");
    });

});

$( document).ready(function () {
    $('.manage-chemicals').click(function () {
        $('body').addClass('loading');
    });
});
