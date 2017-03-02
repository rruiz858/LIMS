
$(document).ready(function () {
    $('.add-to-list').submit(function () {
        $('body').addClass("loading");
        $.ajax({
            url: this.html,
            context: document.body,
            dataType: "html",
            success: $(window).onload = function (){
                $("#texts").load(window.location + " #texts");
                jQuery(window).trigger('load');
                setTimeout(function () {
                    $body = $("body");
                    $body.removeClass('loading');
                }, 1000);
            }
        })
    });
});
