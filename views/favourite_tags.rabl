collection @tags, :root => 'tags', :object_root => false
node do |tag|
  rc = tag.recipes.count
  mc = tag.meals.count
  ic = tag.ingredients.count
  tot = rc + mc + ic
  {
    :name => tag.name,
    :count => tot,
    :counts => {
      :recipes => rc,
      :meals => mc,
      :ingredients => ic
    }
  }
end
