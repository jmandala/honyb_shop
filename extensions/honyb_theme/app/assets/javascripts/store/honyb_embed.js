function hide_why_buy() {
    $('#why-buy-details').slideUp(400, function() {
        $('#why-buy').removeClass('close');
        $('#banner').removeClass('overlay');
    });


}
function show_why_buy() {
    $('#banner').addClass('overlay');
    
    $('#why-buy-details').slideDown(400, function() {
        $('#why-buy').addClass('close');
    });
}

$(document).ready(function() {

    $('#why-buy').click(function() {
        if ($('#why-buy-details').is(':hidden')) {
            show_why_buy();
        } else {
            hide_why_buy();
        }

    });

    $('#why-buy-hide .hide').click(function() {
        hide_why_buy();
    });

    $('#close').click(function() {
        $('.cboxIframe', window.parent.document).hide();
    });

    $('.whats-this').click(function() {
        $('#security-code-help').toggle();
    })
});
