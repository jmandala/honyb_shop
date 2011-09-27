/**
 This is a collection of javascript functions and whatnot
 under the honyb namespace that does stuff we find helpful.
 **/

(function($) {

    var methods = {
        init : function(options) {
            return this.each(function() {
                // If options exist, merge them with our default settings
                if (options) {
                    $.extend(settings, options);
                }
            });
        },
        collapseable : function(options) {
            var settings = {
                'default' : 'hide',
                'hide_txt': 'hide',
                'show_txt': 'show'
            };

            if (options) {
                $.extend(settings, options);
            }

            this.before('<div class="toggle button">' + settings['hide_txt'] + '</div>');
            
            $('.toggle').click(function() {
                var button = $(this);
                content = button.next();
                
                if (content.is(':visible')) {
                    content.hide();
                    button.html(settings['show_txt']);
                } else {
                    content.show();
                    button.html(settings['hide_txt']);
                }
            });

            if (settings['default'] === 'hide') {
                this.toggle();
                $('.toggle').html(settings['show_txt']);
            }
        }
    };

    $.fn.honyb = function(method) {


        // Method calling logic
        if (methods[method]) {
            return methods[ method ].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || ! method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.tooltip');
        }

    };

    $.honyb = $.fn.honyb;

})(jQuery);


jQuery(document).ready(function($) {

    $('.collapseable').honyb('collapseable', {'default' : 'hide'});


});

