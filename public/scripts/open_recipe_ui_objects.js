//	Open Recipe user interface object graph.
//  By Dave Sag

/**
 * First up this is not a Class but a handy utility for allowing easy inheritance.
 * ref http://blogs.sitepoint.com/javascript-inheritance/
 */
function copy_prototype(a_descendant, a_parent) {
	var constructor = a_parent.toString(),
	    match = constructor.match( /\s*function (.*)\(/ );
	if (match !== null) a_descendant.prototype[match[1]] = a_parent;
	for (p in a_parent.prototype) {
		a_descendant.prototype[p] = a_parent.prototype[p];
	}
}

// core objects

function Quantity(an_amount, an_allowed_unit) {
  this.amount = an_amount;
  this.unit_id = an_allowed_unit;
}

function ActiveIngredient(an_ingredient, a_quantity) {
  this.ingredient = an_ingredient;
  this.quantity = a_quantity;
}

function Recipe(an_id, a_name, a_serves, a_cooking_time, a_prep_time, a_description,
                a_method, a_requirements, some_active_ingredients, some_tags, a_meal) {
  this.id = an_id;
  this.name = a_name;
  this.serves = a_serves;
  this.cooking_time = a_cooking_time;
  this.prep_time = a_prep_time;
  this.description = a_description;
  this.method = a_method;
  this.requirements = a_requirements;
  this.active_ingredients = some_active_ingredients;
  this.tags = some_tags;
  this.meal = a_meal;
}

Recipe.fromForm = function(form) {
  // do nothing. This method must be overwritten by form specific logic.
}

Recipe.prototype.toForm = function(form) {
  // do nothing. This method must be overwritten by form specific logic.
}

Recipe.populate = function(data_or_url, form) {
  if (typeof data_or_url === 'string') return Recipe.populate_from_url(data_or_url, form, Recipe.populate_from_data);
  return Recipe.populate_from_data(data_or_url);
}
Recipe.populate_from_data = function(data, form) {
  // console.log("incoming data and form", [data, form]);
  // Recipe(an_id, a_name, a_serves, a_cooking_time, a_prep_time, a_description,
  //        a_method, a_requirements, some_active_ingredients, some_tags, a_meal)
  var active_ingredients = [],
      aid, result;
  for (i in data.active_ingredients) {
    // active_ingredients.push(/* new active ingredient */);
    aid = data.active_ingredients[i].active_ingredient;
    active_ingredients.push(new ActiveIngredient(aid.name, new Quantity(aid.quantity.amount, aid.quantity.unit_id)));
  }
  result = new Recipe(data.id, data.name, data.serves, data.cooking_time, data.preparation_time,
                      data.description, data.method, data.requirements, active_ingredients, null, data.meal_id);  // no tags yet.
  // console.log("returning recipe", result);
  result.toForm(form);
}

// override this if you want it to populate a specific form. 
Recipe.populate_from_url = function(a_url, form, callback) {
  $.get(a_url, function(data) {
    // console.log("got data", data.recipe);
    this.recipe = callback(data.recipe, form);
  });
}

// request message containers.

/**
 * Root class for all the following requests.
 * Defines post_path and post_data methods.
 * You must override this.path in your subclasses for this.post_path() to return the right result.
 */
function Request_Base() {
	this.path = '';
}
Request_Base.prototype.post_path = function() {
	return this.path;
}
Request_Base.prototype.post_data = function() {
	return JSON.stringify(this, null, 2);
}

function Recipe_Request(a_recipe) {
	this.recipe = a_recipe;
	this.path = '/recipe-request';
}
copy_prototype(Recipe_Request, Request_Base);

// other miscellaneous interface bits

function convert_to_options_html(a_map_of_options) {
  var result = '',
      group_count = 0,
      io;
  for (i in a_map_of_options) {
    io = a_map_of_options[i];
    if (io['kind'] == 'option') {
      result += '<option value = "' + io['value'] + '">' + io['label'] + '</option>';
    } else {
      if (group_count > 0) {
        result += '</optgroup>';
        group_count--;
      }
      result += '<optgroup label = "' + io['label'] + '">';
      group_count++;
    }
  }
  if (group_count > 0) {
    result += '</optgroup>';
    group_count--;
  }
  return result;
}

function create_blank_ingredients_row(a_row_number) {
  return "<tr><td><input class='ingredient ui-state-default ui-corner-all' id='ingredient" + 
              a_row_number + "' name='ingredient" + a_row_number + "'></td>" +
           "<td><input class='amount ui-state-default ui-corner-all' id='amount" + 
              a_row_number + "' name='ingredient" + a_row_number + "'></td>" +
           "<td><select class='unit-menu ui-state-default ui-corner-all' id='unit" +
            a_row_number + "' name='ingredient" + a_row_number + "'></select></td></tr>";
}
