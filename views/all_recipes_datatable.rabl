# returns a summary of the recipe list, formatted for jQuery DataTables
# todo: add photos.

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
      '1' => UnicodeUtils::titlecase(user_owns?(r) ? t.ui.you : r.owner.name ),
      '2' => summarise(r.description),
      '3' => human_readable_time(r.preparation_time),
      '4' => human_readable_time(r.cooking_time),
      '5' => r.preparation_time,
      '6' => r.cooking_time
    }
  end
end
