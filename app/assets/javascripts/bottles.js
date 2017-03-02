$(document).ready(function () {
    $('#bottle-search').DataTable({
        "processing": true,
        "paging": true,
        "order": [[5, "desc"]],
        "fnRowCallback": function(nRow, aData, iDisplayIndex) {
            if (aData[6] === "0" || aData[6].length === 0) {
                $(nRow).css('background-color', '#ffe6e6');
            }
        }
    });
});