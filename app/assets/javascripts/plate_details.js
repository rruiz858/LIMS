$(document).ready(function () {
    $('table.details').DataTable({
        "paging": true,
        "scrollX": true,
        "order": [[ 0, 'asc' ], [ 1, 'asc' ]],
        "columnDefs": [{
            "targets": 0,
            "width": "10%"
        }, {
            "targets": 1,
            "width": "10%"
        }, {
            "targets": 2,
            "width": "10%"
        }, {
            "targets": 3,
            "width": "10%"
        }, {
            "targets": 4,
            "width": "15%"
        }, {
            "targets": 5,
            "width": "10%"
        }, {
            "targets": 6,
            "width": "10%"
        }, {
            "targets": 7,
            "width": "10%"
        }, {
            "targets": 8,
            "width": "10%"
        }, {
            "targets": 9,
            "sortable": false
        }]
    });
});
