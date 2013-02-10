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
