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
  "choose-photo" : function () {
    console.log('choose a recipe photo from your facebook photos.');  // enhance this later
    // see example at http://code.google.com/p/facebook-photo-picker/
    // and a jQuery one at https://github.com/seanhellwig/jQuery-Facebook-Multi-Photo-Selector
  },
  "save-recipe" : function () {
    console.log("saving recipe.");
    // go through the form and collect all the fields into a
    // recipe object.
    var ingredients = new Array();
    var number_of_ingredients = $('#ingredients .ingredient').length
    for (i = 0; i < number_of_ingredients ; i++ ) {
      var n = $('#ingredient'+i).val();
      var a = $('#amount'+i).val();
      var u = $('#unit'+i).val();
      console.log ("ingredient = " + n + ", amount = " + a + ", unit = " + u);
      if (n != '') {
        q = new Quantity(a, u);
        ingredients.push(new ActiveIngredient(n,q));
      }
    }
    // merge cooking and prep time fields into a nice time string
    // in dd:hh:mm format
    var ct = to_seconds($('#cooking-time-days').val(),
                        $('#cooking-time-hours').val(),
                        $('#cooking-time-minutes').val());
    var pt = to_seconds($('#prep-time-days').val(),
                        $('#prep-time-hours').val(),
                        $('#prep-time-minutes').val());
    var r = new Recipe(recipe_id, $('#recipe-name').val(), parseInt($('#serves').val()), ct, pt, $('#description').val(),
        $('#method').val(), $('#requirements').val(), ingredients, null, null); // ignore tags and meal for now.
    var req = new Recipe_Request(r);
    console.log('created recipe request object', req);

    // now fire off an AJAX post to the server.
    $.post(req.post_path(), req.post_data(), function(data){
      console.log('debug', data)
      if (!data['success']) {
        // there was an error.
        console.log('error', data['error']);
        // do something to tell the user about this error.
      } else {
        // there is a message
        console.log('message', data['message']);
        // perhaps do something with this message.
        location.href = '/';
      }
    }).error(function() {
        alert(SERVER_ERROR);
    });
  },
  "cancel" : function () {
    // check if there have been any changes.
    console.log("Cancel clicked");
    location.href = '/';
  }
}

$(function(){
  if (recipe_id == 0) {
    // set up three ingredient rows, with appropriate Unit menus
    for (i = 0; i < 3; i++) {
      var i_row = $(create_blank_ingredients_row(i));
      i_row.appendTo('#ingredients tbody');
    }
    $(default_allowed_unit_options).appendTo('#ingredients .unit-menu');
  }
  $('#ingredients .ingredient').autocomplete(ingredient_name_autocompleter);

  $("input:submit").button({
    create: function(event, ui) {
      $(this).val(button_names[$(this).attr('id')]);
    }
  }).click(function(event) {
    event.preventDefault();
    button_handlers[$(this).attr('id')]();
  });
});
