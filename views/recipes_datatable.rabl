# returns a summary of the recipe list, formatted for jQuery DataTables

node do
  {
    'sEcho' => @echo,
    'iTotalRecords' => @recipes.count,
    'iTotalDisplayRecords' => @recipes.count
  }
end
node :aaData do
  @recipes.map do |r|
    {
      'DT_RowId' => "#{@table_name}-id-#{r.id}",
      '0' => UnicodeUtils::titlecase(r.name),
      '1' => UnicodeUtils::titlecase(t.people(r.serves)),
      '2' => summarise(r.description),
      '3' => human_readable_time(r.preparation_time),
      '4' => human_readable_time(r.cooking_time),
      '5' => r.serves,
      '6' => r.preparation_time,
      '7' => r.cooking_time
    }
  end
end
