$(document).ready(function () {
   var comitTable=  $('#comits_index_id').DataTable({
        "paging": true,
        "order" : [[0, "desc"]],
        "scrollY": 400,
        "columnDefs": [{
            "targets": 0,
            "width": "15%"
        }, {
            "targets": 1,
            "width": "30%"
        }, {
            "targets": 2,
            "width": "10%"
        }, {
            "targets": 3,
            "sortable": false,
            "width": "45%"
        }]
    });
    $('.comit-bar').each(function () {
        console.log($(this).attr('id'));
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
                                text: 'Error occurred with COMIT',
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
                        $(progressStatus).text(job.progress_current + '/' + job.progress_max + " \Bottles Added");
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
                            text: 'COMIT was successfully uploaded, please wait for page to reload',
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

    $('.popOverComit').popover();
    $('.popOverComit').on('click', function (e) {
        $('.popOverComit').not(this).popover('hide');
    });

});

























