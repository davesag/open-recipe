require 'test-unit'
require './test/handler_test_base'

class AllowedUnitTest < HandlerTestBase

  def test_seeded_unit_names
    ActiveRecord::Base.transaction do |t|
      # load the seed units
      unit_types = []
      units = []
      uts = YAML.load(File.read('./config/units.yml'))
      
      uts.each do |ut|
        key = ut.keys.first
        unit_types << unit_type = UnitType.where(:name => key).first_or_create
        
        ut[key].each do |u|
          units << au = AllowedUnit.where(:name => u.to_s).first_or_create(:unit_type => unit_type)
        end
      end

      # now check that they all correspond to units known by Ruby Units.
      
      units.each do |u|
        unit = Unit(u.name);
        # puts app.settings.t.units unit.unit_name, 1
        # see http://stackoverflow.com/questions/12335676/accessing-t-from-r18n-in-a-rack-unit-test-of-a-sinatra-app
      end

      units.each {|u| u.destroy}
      unit_types.each {|u| u.destroy}
    end
    assert UnitType.count == 0, "There #{UnitType.count == 1 ? 'is' : 'are'} #{UnitType.count} UnitType#{UnitType.count == 1 ? '' : 's'} left over."
    assert AllowedUnit.count == 0, "There #{AllowedUnit.count == 1 ? 'is' : 'are'} #{AllowedUnit.count} Unit#{AllowedUnit.count == 1 ? '' : 's'} left over."
  end

end
