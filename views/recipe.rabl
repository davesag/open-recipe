object @recipe
attributes :id, :name, :cooking_time, :preparation_time, :method, :requirements, :description, :serves, :meal_id
child :active_ingredients do
  node do |ai|
    {
      :name => ai.ingredient.name,
      :quantity => {
        :amount => ai.quantity.amount.to_f,
        :unit_id => (ai.quantity.unit ? ai.quantity.unit.id : nil)
      }
    }
  end
end
child :photos do
  node do |photo|
    {
      :id => photo.id,
      :name => photo.name,
      :remote_id => photo.remote_id,
      :remote_id => photo.remote_id,
      :image_url => photo.image_url,
      :thumbnail_url => photo.thumbnail_url,
    }
  end
end
