$(document).ready(function () {
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        $.fn.dataTable.tables({visible: true, api: true}).columns.adjust();
    });
    $('#coas-index-table').DataTable({
        "processing": true,
        "paging": true,
        "scrollY": true,
        "scrollX": true,
        "serverSide": true,
        "sAjaxSource": $('#coas-index-table').data('source')
    });
    $('#msds-index-table').DataTable({
        "processing": true,
        "paging": true,
        "scrollY": true,
        "scrollX": true,
        "serverSide": true,
        "sAjaxSource": $('#msds-index-table').data('source')
    });
});

