$(document).ready(function () {
    $('#users_index_id').DataTable({
        "paging": true

    });
    var num = "5";
    $('#cor-input').bind('change', function () {
        if (this.value === num) {
            $('#cor-names').show();
            if ($("#cor-options option:selected").length > 0) {
                $("#submitUserButton").attr('disabled', false);
            } else {
                $("#submitUserButton").attr('disabled', true);
            }
        } else {
            $('#cor-names').hide();
            $("#cor-options > option").attr("selected", false);
            $("#submitUserButton").attr('disabled', false);
        }
    }).trigger('change');

    $('#cor-options').bind('change', function () {
     if ( $('#cor-input').val() === num)    {
        if ($("#cor-options option:selected").length > 0) {
            $("#submitUserButton").attr('disabled', false);
        } else {
            $("#submitUserButton").attr('disabled', true);
        }
    }
    })
});