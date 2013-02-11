/**
 *  A collection of methods for handling the recipe form.
 * Includes:
 * - defines ingredient_name_autocompleter object, as per jQuery UI autocompleter.
 * - defines button_handlers object that specifies handlers for 'choose-photo', 'save-recipe', and 'cancel'
 * - overrides Recipe.prototype.toForm,
 * - overrides Recipe.fromForm,
 * todo - define a duration object with valid(), to_string() and parse() methods.
 */

var ingredient_name_autocompleter = {
      source: all_ingredient_names,
      change: function(){
        var this_row = $(this).parent().parent(),
            new_row_number, new_row;
        if (this_row.is(':last-child')) {
          // add another row.
          new_row_number = this_row.siblings('tr').length + 1;
          $(create_blank_ingredients_row(new_row_number)).appendTo(this_row.parent());
          new_row = this_row.next();
          $(default_allowed_unit_options).appendTo(new_row.find('.unit-menu'));
          new_row.find('.ingredient').autocomplete(ingredient_name_autocompleter);
        }
      }
    },
  button_handlers = {
    "choose-photo" : function (event) {
      event.preventDefault();
      console.log('choose a recipe photo from your facebook photos.');  // enhance this later
      // see example at http://code.google.com/p/facebook-photo-picker/
      // and a jQuery one at https://github.com/seanhellwig/jQuery-Facebook-Multi-Photo-Selector
    },
    "save-recipe" : function (event) {
      event.preventDefault();
      var form = $(this).parents("form:first"),
          r, req;
      if (form.valid()) {
        r = Recipe.fromForm(form);
        req = new Recipe_Request(r);

        // now fire off an AJAX post to the server.
        $.post(req.post_path(), req.post_data(), function(data){
          //console.log('debug', data)
          if (!data['success']) {
            // there was an error.
            // console.log('error', data['error']);
            // todo: tell the user about this error.
          } else {
            // console.log('message', data['message']);
            // todo: perhaps do something with this message.
            location.href = '/';
          }
        }).error(function() {
            alert(ERROR_MESSAGES['server']);
        })
      }
    },
    "cancel" : function (event) {
      event.preventDefault();
      // check if there have been any changes.
      // console.log("Cancel clicked");
      location.href = '/';
    }
  }

// Maps a Recipe object to the recipe form.
// Overrides the default toForm method.
Recipe.prototype.toForm = function(form) {
  var last_row = $(create_blank_ingredients_row(this.active_ingredients.length)),
      ai, row, unit_menu;

  $("#recipe-name").val(this.name);
  $("#description").val(this.description);
  $("#serves").val(this.serves);
  $("#prep-time").val(toDurationString(this.prep_time));  // todo: standardise this.
  $("#cooking-time").val(toDurationString(this.cooking_time));
  $("#the-method").val(this.method);
  $("#requirements").val(this.requirements);

  for (i in this.active_ingredients) {
    ai = this.active_ingredients[i];
    row = $(create_blank_ingredients_row(i));
    row.appendTo('#ingredients tbody');
    // add values.
    row.find("#ingredient" + i).val(ai.ingredient);
    row.find("#amount" + i).val(ai.quantity.amount);
    unit_menu = row.find("#unit" + i);
    $(default_allowed_unit_options).appendTo(unit_menu);
    unit_menu.val(ai.quantity.unit_id);
  }
  // add one blank one to the end.
  last_row.appendTo('#ingredients tbody');
  $(default_allowed_unit_options).appendTo(last_row.find("select"));
  $("input.ingredient").autocomplete(ingredient_name_autocompleter);
}

// recipe mappings for a jQuery form object.
// overrides the default fromForm method.
Recipe.fromForm = function(form) {
  // go through the form and collect all the fields into a
  // recipe object.
  var ingredients = [],
      number_of_ingredients = $('#ingredients .ingredient').length,
      ct = parseDuration($('#cooking-time').val()),
      pt = parseDuration($('#prep-time').val()),
      n, a, u, q;

  for (i = 0; i < number_of_ingredients ; i++ ) {
    n = $('#ingredient'+i).val();
    a = $('#amount'+i).val();
    u = $('#unit'+i).val();
    if (n !== '') {
      console.log ("ingredient = " + n + ", amount = " + a + ", unit = " + u);
      q = new Quantity(a, u);
      ingredients.push(new ActiveIngredient(n,q));
    }
  }
  return new Recipe(recipe_id, $('#recipe-name').val(), parseInt($('#serves').val()), ct, pt, $('#description').val(),
      $('#the-method').val(), $('#requirements').val(), ingredients, null, null); // ignore tags and meal for now.
}

function to_seconds(d,hh,mm) {
  return d * 24 * 60 * 60 +
         hh * 60 * 60 +
         mm * 60;
}

// expects 1d 11h 11m, or 1d 11h, or 11h 11m, or 11h, or 11m, or 1d
// returns a number of seconds.
function parseDuration(sDuration) {
  if (sDuration == null || sDuration === '') {
    // console.log("sDuration was null or void.", sDuration);
    return 0;
  }
  var mrx = new RegExp(/([0-9][0-9]?)[ ]?m/),
      hrx = new RegExp(/([0-9][0-9]?)[ ]?h/),
      drx = new RegExp(/([0-9])[ ]?d/),
      days = 0,
      hours = 0,
      minutes = 0;

  if (mrx.test(sDuration)) minutes = parseInt(mrx.exec(sDuration)[1]);
  if (hrx.test(sDuration)) hours = parseInt(hrx.exec(sDuration)[1]);
  if (drx.test(sDuration)) days = parseInt(drx.exec(sDuration)[1]);
  return to_seconds(days, hours, minutes);
}

// outputs a duration string based on the number of seconds provided.
// rounded off to the nearest 1 minute.
function toDurationString(iDuration) {
  if (iDuration <= 0) return '';
  var m = Math.floor((iDuration/60)%60), // discard seconds.
      h = Math.floor((iDuration/3600)%24),
      d = Math.floor(iDuration/86400),
      result = '';

  if (d > 0) result = result + d + 'd ';
  if (h > 0) result  = result + h + 'h ';
  if (m > 0) result  = result + m + 'm ';
  return result.substring(0, result.length - 1);
}

function validate_duration(value, element) {
  var elm = $(element),
      v = elm.val(),
      secs = parseDuration(v);

  return (this.optional(element) || (secs !== 0 || (v === '0' || v === '')));
}

$(function(){
  $.validator.addMethod("duration", validate_duration);

  if (recipe_id == 0) {
    // set up three ingredient rows, with appropriate Unit menus
    for (i = 0; i < 3; i++) {
      $(create_blank_ingredients_row(i)).appendTo('#ingredients tbody');
    }
    $(default_allowed_unit_options).appendTo('#ingredients .unit-menu');
  }
  $('#ingredients .ingredient').autocomplete(ingredient_name_autocompleter);
});
