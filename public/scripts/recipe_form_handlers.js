var ingredient_name_autocompleter = {
  source: all_ingredient_names,
  change: function(){
    var this_row = $(this).parent().parent();
    if (this_row.is(':last-child')) {
      // add another row.
      var new_row_number = this_row.siblings('tr').length + 1;
      $(create_blank_ingredients_row(new_row_number)).appendTo(this_row.parent());
      var new_row = this_row.next();
      $(default_allowed_unit_options).appendTo(new_row.find('.unit-menu'));
      new_row.find('.ingredient').autocomplete(ingredient_name_autocompleter);
    }
  }
};

var button_handlers = {
  "choose-photo" : function (event) {
    event.preventDefault();
    console.log('choose a recipe photo from your facebook photos.');  // enhance this later
    // see example at http://code.google.com/p/facebook-photo-picker/
    // and a jQuery one at https://github.com/seanhellwig/jQuery-Facebook-Multi-Photo-Selector
  },
  "save-recipe" : function (event) {
    event.preventDefault();
    //console.log("saving recipe via event:", event);
    var form = $(this).parents("form:first");
    //console.log("target form: ", form);
    if (form.valid()) {
      var r = Recipe.fromForm(form);
      console.log(r);
      var req = new Recipe_Request(r);
      console.log('created recipe request object', req);

      // now fire off an AJAX post to the server.
      $.post(req.post_path(), req.post_data(), function(data){
        //console.log('debug', data)
        if (!data['success']) {
          // there was an error.
          console.log('error', data['error']);
          // todo: tell the user about this error.
        } else {
          // there is a message
          console.log('message', data['message']);
          // todo: perhaps do something with this message.
          location.href = '/';
        }
      }).error(function() {
          alert(ERROR_MESSAGES['server']);
      });
    }
  },
  "cancel" : function (event) {
    event.preventDefault();
    // check if there have been any changes.
    // console.log("Cancel clicked");
    location.href = '/';
  }
}

// recipe mappings for a jQuery form object.
Recipe.fromForm = function(form) {
  // go through the form and collect all the fields into a
  // recipe object.
  var ingredients = new Array();
  var number_of_ingredients = $('#ingredients .ingredient').length
  for (i = 0; i < number_of_ingredients ; i++ ) {
    var n = $('#ingredient'+i).val();
    var a = $('#amount'+i).val();
    var u = $('#unit'+i).val();
    if (n !== '') {
      console.log ("ingredient = " + n + ", amount = " + a + ", unit = " + u);
      q = new Quantity(a, u);
      ingredients.push(new ActiveIngredient(n,q));
    }
  }
  var ct = parseDuration($('#cooking-time').val());
  var pt = parseDuration($('#prep-time').val());
  var r = new Recipe(recipe_id, $('#recipe-name').val(), parseInt($('#serves').val()), ct, pt, $('#description').val(),
      $('#the-method').val(), $('#requirements').val(), ingredients, null, null); // ignore tags and meal for now.
  return r;
}

function to_seconds(d,hh,mm) {
  t = d * 24 * 60 * 60 +
      hh * 60 * 60 +
      mm * 60;
  return t;
}

// expects 1d 11h 11m, or 1d 11h, or 11h 11m, or 11h, or 11m, or 1d
// returns a number of seconds.
function parseDuration(sDuration) {
  if (sDuration == null || sDuration === '') {
    // console.log("sDuration was null or void.", sDuration);
    return 0;
  }
  mrx = new RegExp(/([0-9][0-9]?)[ ]?m/);
  hrx = new RegExp(/([0-9][0-9]?)[ ]?h/);
  drx = new RegExp(/([0-9])[ ]?d/);
  days = 0;
  hours = 0;
  minutes = 0;
  if (mrx.test(sDuration)) {
    minutes = parseInt(mrx.exec(sDuration)[1]);
    // console.log("minutes = ", minutes);
  }
  if (hrx.test(sDuration)) {
    hours = parseInt(hrx.exec(sDuration)[1]);
    // console.log("minutes = ", hours);
  }
  if (drx.test(sDuration)) {
    days = parseInt(drx.exec(sDuration)[1]);
    // console.log("days = ", days);
  }
  
  return to_seconds(days, hours, minutes);
}

// outputs a duration string based on the number of seconds provided.
// rounded off to the nearest 1 minute.
function toDurationString(iDuration) {
  if (iDuration <= 0) return '';
  var m = Math.floor((iDuration/60)%60); // discard seconds.
  var h = Math.floor((iDuration/3600)%24);
  var d = Math.floor(iDuration/86400);
  result = ''
  if (d > 0) result = result + d + 'd ';
  if (h > 0) result  = result + h + 'h ';
  if (m > 0) result  = result + m + 'm ';
  return result.substring(0, result.length - 1);
}

$(function(){
  $.validator.addMethod("duration", function(value, element) {
    var elm = $(element)
    var v = elm.val();
    var secs = parseDuration(v);
    if (this.optional(element) || (secs !== 0 || (v === '0' || v === ''))) return true;
    return false;
  });

  if (recipe_id == 0) {
    // set up three ingredient rows, with appropriate Unit menus
    for (i = 0; i < 3; i++) {
      var i_row = $(create_blank_ingredients_row(i));
      i_row.appendTo('#ingredients tbody');
    }
    $(default_allowed_unit_options).appendTo('#ingredients .unit-menu');
  }
  $('#ingredients .ingredient').autocomplete(ingredient_name_autocompleter);
});
