
$(document).ready(function () {
    $('.coa-summary-bar').each(function () {
        var interval;
        var job_id;
        var progressBar;
        var progressStatus;
        var progressActivity;
        job_id = $(this).attr('id');
        progressBar = $(this).find(".progress-bar");
        progressStatus = $(this).find(".progress-status");
        progressActivity = $(this).find(".progress");
        $(progressActivity).show();
        interval = setInterval(function(){
            $.ajax({
                url: '/progress-job/' + job_id,
                success: function(job){
                    var stage, progress;
                    // If there are errors
                    if (job.last_error != null) {
                        $(progressActivity).removeClass('active');
                        $(progressStatus).addClass('text-danger').text(job.progress_stage);
                        $(progressBar).removeClass('progress-bar-info').addClass('progress-bar-danger');
                        clearInterval(interval);
                        $(function () {
                            new PNotify({
                                title: 'Error',
                                text: 'Error occurred with COA Summmary File',
                                type: 'error',
                                animation: 'show',
                                hide: false,
                                buttons: {
                                    sticker: false
                                }

                            });
                        });
                    }
                    progress = job.progress_current / job.progress_max * 100;
                    // In job stage
                    if (progress.toString() !== 'NaN'){
                        $(progressStatus).text(job.progress_current + '/' + job.progress_max + " \Coa Summaries Added");
                        $(progressBar).css('width', progress + '%').text(progress.toFixed(0) + '%');
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    // Job is no loger in database which means it finished successfuly
                    $(progressActivity).removeClass('active');
                    $(progressBar).removeClass('progress-bar-info progress-stripped').addClass('progress-bar-success');
                    $(progressBar).css('width', '100%').text('100%' + 'Complete');
                    $(progressStatus).text('Successfully Completed, Please Wait!');
                    clearInterval(interval);
                    window.location.reload(true);
                    $(function () {
                        new PNotify({
                            title: 'Success',
                            text: 'COA Summmary File was succesfully uploaded, please wait for page to reload',
                            type: 'success',
                            animation: 'show',
                            hide: false,
                            buttons: {
                                sticker: false
                            }

                        });
                    });
                }
            })

        },500);

    });
    $('a[data-toggle="tab"]').on( 'shown.bs.tab', function (e) {
        $.fn.dataTable.tables( {visible: true, api: true} ).columns.adjust();
    } );
    $('#curated-coas').DataTable({
        "processing": true,
        "serverSide": true,
        "sAjaxSource": $('#curated-coas').data('source'),
        "paging": true,
        "columnDefs": [{
            "targets": [10,11,12],
            "orderable": false
        }
        ]

    });

    $('#coa-summary-files-index-id').DataTable({
        "paging": true,
        "order" : [[0, "desc"]],
        "columnDefs": [{
            "targets": 0,
            "width": "15%"
        }, {
            "targets": 1,
            "width": "5%"
        }, {
            "targets": 2,
            "width": "15%"
        }, {
            "targets": 3,
            "sortable": false
        }]
    });

    $('.popOverComit').popover();
    $('.popOverComit').on('click', function (e) {
        $('.popOverComit').not(this).popover('hide');
    });


    function uncuratedCoas() {
        var uncuratedTable = null;
        var curateRoute = $("#curate-coas-div").data('curateroute');
        var typeRoute = $("#tables-url").data('matchtables');
        $('table.display').each(function () {
            var tableId = $(this).attr('id');
            var linkClass = 'a#' + tableId + '-match';
            $(document).on('click', linkClass, function (e) {
                var newTableId = tableId + '-match-form';
                var formId = $(this).attr("id") + '-form';
                if (newTableId === formId) {
                    if ($.fn.DataTable.isDataTable('#' + tableId)) {
                        $('table.matchedKindClass').each(function (i) {
                            var oldId = $(this).attr('id');
                            if (oldId === tableId) {
                                var oldTable = $('#' + tableId).DataTable({
                                    processing: true,
                                    retrieve: true,
                                    "paging": true,
                                    "columnDefs": [{
                                        "targets": [0, 2, 4, 5],
                                         "width": "5%"
                                     }, {
                                            "targets": [7, 8], "visible": false
                                        }],
                                    "fnRowCallback": function (nRow, aData, iDisplayIndex) {
                                        if (aData[7] !== '1') {
                                            $('td:eq(1)', nRow).css('background-color', '#ffe6e6');
                                        }
                                        if (aData[8] !== '1') {
                                            $('td:eq(2)', nRow).css('background-color', '#ffe6e6');
                                        }
                                    }
                                });
                                $.ajax({
                                        type: "POST",
                                        url: typeRoute,
                                        data: {kind: tableId},
                                        dataType: "json"
                                    }).done(function (result) {
                                        oldTable.clear().draw();
                                        oldTable.rows.add($(result.html)).draw();
                                    }).fail(function (jqXHR, textStatus, errorThrown) {
                                    console.log(errorThrown)
                                    });
                                }
                            }
                        );
                    } else {
                        var tableIdString = '#' + tableId;
                        var uncuratedTable = $('#' + tableId).DataTable({
                            processing: true,
                            retrieve: true,
                            "paging": true,
                            "columnDefs": [{
                                "targets": [0, 2, 4, 5],
                                "width": "5%"
                            }, {
                                "targets": [7, 8], "visible": false
                            }],
                            "fnRowCallback": function (nRow, aData, iDisplayIndex) {
                                if (aData[7] !== '1') {
                                    $('td:eq(1)', nRow).css('background-color', '#ffe6e6');
                                }
                                if (aData[8] !== '1') {
                                    $('td:eq(2)', nRow).css('background-color', '#ffe6e6');
                                }
                            }
                        });
                        $.ajax({
                            type: "POST",
                            url: typeRoute,
                            data: {kind: tableId},
                            dataType: "json"
                        }).done(function (result) {
                            uncuratedTable.clear().draw();
                            uncuratedTable.rows.add($(result.html)).draw();
                            bindValidateButtons(tableId, uncuratedTable);
                        }).fail(function (jqXHR, textStatus, errorThrown) {
                            console.log(errorThrown)
                        });
                    }
                }
            });
        });

        var multipleGsidTable = '#curateMultipleGsid tbody';
        $(multipleGsidTable).on('click', ".curate-coa", function () {
            var oldTable = $('#name-other').DataTable({
                processing: true,
                retrieve: true,
                "paging": true,
                "columnDefs": [{
                    "targets": [0, 2, 4, 5],
                    "width": "5%"
                }, {
                    "targets": [7, 8], "visible": false
                }],
                "fnRowCallback": function (nRow, aData, iDisplayIndex) {
                    if (aData[7] === '1') {
                        $('td:eq(3)', nRow).css('background-color', '#ffe6e6');
                    }
                    if (aData[8] === '1') {
                        $('td:eq(4)', nRow).css('background-color', '#ffe6e6');
                    }
                }
            });

            var ssId = $(this).attr('id');
            var gsId = $(this).closest('tr').attr('id');
            $.ajax({
                type: "POST",
                url: curateRoute,
                data: {ssId: ssId, gsId: gsId},
                dataType: "json",
                success: function (msg) {
                    $("#overrideModal").modal('hide');
                    $.ajax({
                        type: "POST",
                        url: typeRoute,
                        data: {kind: 'name-other'},
                        dataType: "json"
                    }).done(function (result) {
                        oldTable.clear().draw();
                        oldTable.rows.add($(result.html)).draw();
                    }).fail(function (jqXHR, textStatus, errorThrown) {
                        console.log(errorThrown)
                    });
                    $(function () {
                        new PNotify({
                            title: 'Success',
                            text: 'Successfully curated record',
                            type: 'success',
                            animation: 'show',
                            hide: false,
                            buttons: {
                                sticker: false
                            }

                        });
                    });
                    updateTotalUncuratedCount();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $(function () {
                        new PNotify({
                            title: 'Error',
                            text: errorThrown,
                            type: 'error',
                            animation: 'show',
                            hide: false,
                            buttons: {
                                sticker: false
                            }

                        });
                    });

                }
            });
        });
    }

    function bindValidateButtons(tableId, LoadedDataTable) {
        var typeRoute = $("#tables-url").data('matchtables');
        var curateRoute = $("#curate-coas-div").data('curateroute');
        var tbodySelector = '#' + tableId + ' tbody';
        $(tbodySelector).on('click', '.curate-coa', function () {
            var ssId = $(this).attr('id');
            var gsId = $(this).closest('tr').find('.gsid-coa').text();
            $.ajax({
                type: "POST",
                url: curateRoute,
                data: {ssId: ssId, gsId: gsId},
                dataType: "json",
                success: function (msg) {
                    $.ajax({
                        type: "POST",
                        url: typeRoute,
                        data: {kind: tableId},
                        dataType: "json"
                    }).done(function (result) {
                        LoadedDataTable.clear().draw();
                        LoadedDataTable.rows.add($(result.html)).draw();
                    }).fail(function (jqXHR, textStatus, errorThrown) {
                        console.log(errorThrown)
                    });
                    $(function () {
                        new PNotify({
                            title: 'Success',
                            text: 'Successfully curated record',
                            type: 'success',
                            animation: 'show',
                            hide: false,
                            buttons: {
                                sticker: false
                            }

                        });
                    });
                    updateTotalUncuratedCount();

                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $(function () {
                        new PNotify({
                            title: 'Error',
                            text: errorThrown,
                            type: 'error',
                            animation: 'show',
                            hide: false,
                            buttons: {
                                sticker: false
                            }

                        });
                    });
                }
            });

        });
    }

    $("#coaSummaryIndex").load(uncuratedCoas(), showTabs());
    //re-initialized function when Modal is called
    $(document).bind('ajax:success', '#curateMutlitpleGsidDiv', function () {
        uncuratedCoas();
    });
        $("a#uncuratedTag").on('click', function () {
            var countRoute = $("#uncuratedCountsDiv").data('countroute');
            $.ajax({
                type: 'GET',
                url: countRoute,
                success: function(data,status,xhr){
                    $("ul#uncuratedList").html("<li class='dropdown-header'>Matched Types</li>");
                    for (var key in data){
                        if (data[key] >= 1 ){
                            var id = key.replace(/_/, '-');
                            $("ul#uncuratedList").append("<li>" + "<a title = '' data-original-title=''" + " href='#' id='" + id + "-match'" + " class='show " + id + "-link'" + " data-toggle='tab' " + '>'  +
                                "<div> <span class= 'badge pull-right'" + "id='badge" + id +"'>"+ data[key] +"</span>" + id + "</div></a>" +
                                "</li> ");
                        }
                    }
                    $("ul#uncuratedList").append("</li>");
                    updateTotalUncuratedCount();
                    showTabs();
                },
                error: function(xhr,status,error){
                    console.log(xhr);
                }
            });
        });

    function showTabs() {
        $(".show").off('click').on("click",function () {
            var id = $(this).attr("id");
            var formId = '#' + id + '-form';
            $(".coa-form").not(id).hide(200);
            $(formId).removeClass('hidden');
            $(formId).show(100);
        })
    }

    function updateTotalUncuratedCount(){
        var totalCountRoute = $("#totalCountDiv").data('totalcountroute');
        $.ajax({
            type: 'GET',
            url: totalCountRoute,
            success: function(data,status,xhr){
                if (data.uncurated_count >= 1 ) {
                    $('#uncuratedMainCount').html(data.uncurated_count);
                } else {
                    $('#uncuratedDropDown').hide();
                    $('#curated-coa-summaries').click();
                }
            },
            error: function(xhr,status,error){
                console.log(xhr);
            }
        });
    }

});



