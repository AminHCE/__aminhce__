
function setPrint(pageHeight) {
    let newPageHeight = pageHeight
    $('.print').removeClass(function (index, className) {
        return (className.match (/(^|\s)print\S+/g) || []).join(' ');
    });

    $('.main-block').each(function(){
        let elementHeight = $(this).height(),
            elementOffset = $(this).offset().top,
            element       = (elementOffset + elementHeight);

        if(element > newPageHeight){
            if(newPageHeight - elementOffset < pageHeight * 0.025){
                $(this).addClass('print print-40-mm');
                newPageHeight = newPageHeight + pageHeight
                $('body').height(newPageHeight)
            } else if(newPageHeight - elementOffset < pageHeight * 0.05){
                $(this).addClass('print print-50-mm');
                newPageHeight = newPageHeight + pageHeight
                $('body').height(newPageHeight)
            } else if(newPageHeight - elementOffset < pageHeight * 0.075){
                $(this).addClass('print print-60-mm');
                newPageHeight = newPageHeight + pageHeight
                $('body').height(newPageHeight)
            } else if(newPageHeight - elementOffset < pageHeight * 0.1){
                $(this).addClass('print print-70-mm');
                newPageHeight = newPageHeight + pageHeight
                $('body').height(newPageHeight)
            } else if(newPageHeight - elementOffset < pageHeight * 0.125){
                $(this).addClass('print print-80-mm');
                newPageHeight = newPageHeight + pageHeight
                $('body').height(newPageHeight)
            } else if(newPageHeight - elementOffset < pageHeight * 0.15){
                $(this).addClass('print print-90-mm');
                newPageHeight = newPageHeight + pageHeight
                $('body').height(newPageHeight)
            }
            $('.blocks').each(function(){
                let blockHeight = $(this).height(),
                    blockOffset = $(this).offset().top,
                    block       = (blockHeight + blockOffset);

                if(block > newPageHeight){
                    if(newPageHeight - blockOffset < pageHeight * 0.025){
                        $(this).addClass('print print-40-mm');
                        newPageHeight = newPageHeight + pageHeight
                        $('body').height(newPageHeight)
                    } else if(newPageHeight - blockOffset < pageHeight * 0.05){
                        $(this).addClass('print print-50-mm');
                        newPageHeight = newPageHeight + pageHeight
                        $('body').height(newPageHeight)
                    } else if(newPageHeight - blockOffset < pageHeight * 0.075){
                        $(this).addClass('print print-60-mm');
                        newPageHeight = newPageHeight + pageHeight
                        $('body').height(newPageHeight)
                    } else if(newPageHeight - blockOffset < pageHeight * 0.1){
                        $(this).addClass('print print-70-mm');
                        newPageHeight = newPageHeight + pageHeight
                        $('body').height(newPageHeight)
                    } else if(newPageHeight - blockOffset < pageHeight * 0.125){
                        $(this).addClass('print print-80-mm');
                        newPageHeight = newPageHeight + pageHeight
                        $('body').height(newPageHeight)
                    } else if(newPageHeight - blockOffset < pageHeight * 0.15){
                        $(this).addClass('print print-90-mm');
                        newPageHeight = newPageHeight + pageHeight
                        $('body').height(newPageHeight)
                    }
                }
            });
        }
    });
}

$('document').ready(function() {
    let pageHeight = $('body').height()
    $('.more-button').on('click', function() {
        $('.more').toggleClass('hidden');
        $('#more-icon').toggleClass('fa-folder-open-o fa-folder-o')
        setPrint(pageHeight);
    });
    setPrint(pageHeight);
});


