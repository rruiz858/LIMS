$(document).ready(function () {
    $('#orders_index_id').DataTable({
        "paging": true,
        "sScrollX": '100%',
        'sScrollXInner': '105%',
        "order": [[0, "desc"]],
        "columnDefs": [{
            "targets": 0,
            "width": "1%"
        }, {
            "targets": 1,
            "width": "1%"
        }, {
            "targets": 2,
            "width": "1%"
        }, {
            "targets": 3,
            "width": "1%"
        }, {
            "targets": 4,
            "width": "1%"
        }, {
            "targets": 5,
            "width": "1%"
        }, {
            'width': '25%',
            'targets': 6,
            'sortable': false
        }, {
            'width': '1%',
            'targets': 7,
            'sortable': false
        }
        ]
    });
});
