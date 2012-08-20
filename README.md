_Open Recipe_
===========

> Where Facebook friends can upload their own recipies in a standard format
> that be searched and shared easily to their friends.

---

## Features

### _Guests_ have access to the following features

* browse public recipes and photos, and user profiles.
* log in using their Facebook id.

### _Free Members_; Those who don't pay but who do log in via Facebook have access to the following additional features

* upload of recipes and photos for use by anyone under the following
creative commons license 'Attribution-Noncommercial-Share Alike' -
http://creativecommons.org/licenses/by-nc-sa/3.0/au/
* Posting a link to any recipe you can access to your Facebook
timeline, or sharing it with selected friends.
* 'Like' a recipe
* uploading photos linked to a recipe, restaurant, or retailer.
* check in to a location on Facebook, based on photo or recipe upload.

### _Paying Members_; Those who do pay and who log in via Facebook can

* upload recipes under creative commons licence, but whose audience is
restricted to friends only.
* earn reputation credit to allow wider permissions such as
 * editing retailer and restaurant meta-data
 * moderating recipe placement within appropriate meals and meal
types, moderating tags, creation of and merging of retailers,
restaurants, photos, meals and meal-types, and tags.

---

## To Install

### Requirements

* `Mac OS X` with `Developer Tools` and `Ruby 1.9.3` installed, and the following Gems.
 * `Bundler`
 * `Git`
 * `Heroku`
 * `Foreman`

### How to Run _Open Recipe_ on your local Mac

1. Open your Terminal and enter:  
    > `gem install bundler`  
    > `bundle install`  
    > `foreman start`

2. Point your web-browser at `http://localhost:5000`

### Heroku

* A production copy of the app is running at http://open-recipe.herokuapp.com for the moment.

---
