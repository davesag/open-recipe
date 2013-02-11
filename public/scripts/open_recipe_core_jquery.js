/** Load this after you load jQuery and jQuery UI.
 *  Startup stuff that is executed on every page.
 */
$(function() {
  var cache = {}, lastXhr;
  $("#search-field").autocomplete({
    minLength: 2,
    source: function( request, response ) {
      var term = request.term;
      if ( term in cache ) {
        response( cache[ term ] );
        return;
      }
  
      lastXhr = $.getJSON( "/search", request, function( data, status, xhr ) {
        cache[ term ] = data;
        if ( xhr === lastXhr ) {
          response( data );
        }
      });
    },
    select: function (event, ui) {
      // console.log (ui.item ?
      // "Selected: " + ui.item.value + " aka " + ui.item.label :
      // "Nothing selected, input was " + this.value, event);
      return false; // don't update the search field.
    },
    response: function (event, ui) {
      // console.log ('do we ever get here?', event);
    }
    // note the spinner sometimes doesn't stop spinning
    // see http://stackoverflow.com/questions/2519513/spinner-with-jquery-ui-1-8-autocomplete
    // and http://stackoverflow.com/questions/4316071/remove-spinner-from-jquery-ui-autocomplete-if-nothing-found
  });
});
