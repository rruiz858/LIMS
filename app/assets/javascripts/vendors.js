$(document).ready(function () {
    $('#contacts').DataTable({
        "paging": true,
        "scrollY": true,
        "scrollX": true

    });
    $('table.vendors').DataTable({
        "paging": true,
        "scrollY": 600
    });
    $('#agreements').DataTable({
        "paging": true,
        "scrollY": true,
        "scrollX": true
    });

    $('input[type=radio]').change(function (){
            if (this.checked) {
                $(this).closest('.radioButton')
                    .find('input[type=radio]').not(this)
                    .prop('checked', false);
            }
        }
    );
});

