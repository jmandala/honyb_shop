/**
 This is a collection of javascript functions and whatnot
 under the honyb namespace that does stuff we find helpful.
 **/

(function( $ ){

  var methods = {
    init : function( options ) {  },
    collapseable : function() {
        var hide = 'hide';
        var show = 'show';
        this.before('<div class="toggle">' + hide + '</div>');
        $('.toggle').click(function() {          
            var button = $(this);
            content = button.next();
            content.toggle();
            if (content.is(':visible')) {
                button.html(hide);
            } else {
                button.html(show);
            }
        });
    }
  };

  $.fn.honyb = function( method ) {
    
    // Method calling logic
    if ( methods[method] ) {
      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.tooltip' );
    }    
  
  };
    
  $.honyb = $.fn.honyb;

})( jQuery );


jQuery(document).ready(function($) {
    
    $('.collapseable').honyb('collapseable');
    
    
});

