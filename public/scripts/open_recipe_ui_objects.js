//	Open Recipe user interface object graph.
//  By Dave Sag

/**
 * First up this is not a Class but a handy utility for allowing easy inheritance.
 * ref http://blogs.sitepoint.com/javascript-inheritance/
 */
function copy_prototype(a_descendant, a_parent) {
	var constructor = a_parent.toString();
	var match = constructor.match( /\s*function (.*)\(/ );
	if ( match !== null ) { a_descendant.prototype[match[1]] = a_parent; }
	for (var m in a_parent.prototype) {
		a_descendant.prototype[m] = a_parent.prototype[m];
	}
}

function ActiveIngredient(an_ingredient, a_prep, a_quantity) {
  this.ingredient = an_ingredient;
  this.preparation_id = a_prep;
  this.quantity = a_quantity;
}

function Ingredient() {
  this.name = a_name;
  this.description = a_description;
  this.tags = some_tags;
}

function Recipe(an_id, a_name, a_cooking_time, a_prep_time, a_description,
                a_method, a_requirements, some_active_ingredients, some_tags, a_meal) {
  this.id = an_id;
  this.name = a_name;
  this.cooking_time = a_cooking_time;
  this.prep_time = a_prep_time;
  this.description = a_description;
  this.method = a_method;
  this.requirements = a_requirements;
  this.active_ingredients = some_active_ingredients;
  this.tags = some_tags;
  this.meal = a_meal;
}

function Quantity(an_amount,an_allowed_unit) {
  this.amount = an_amount;
  this.unit_id = an_allowed_unit;
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
};
Request_Base.prototype.post_data = function() {
	return JSON.stringify(this, null, 2);
};

function Recipe_Request(a_recipe) {
	this.recipe = a_recipe;
	this.path = '/recipe-request';
}
copy_prototype(Recipe_Request, Request_Base);
