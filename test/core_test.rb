require 'koala'
require 'test-unit'
require './test/handler_test_base'

class CoreTest < HandlerTestBase

  #test creation of Users and related objects.
  def test_human_readable_time
    hrt = human_readable_time 60
    e = '1 m'
    assert e == hrt, "Expected '#{e}' but got '#{hrt}'."
    hrt = human_readable_time 60 * 30
    e = '30 m'
    assert e == hrt, "Expected '#{e}' but got '#{hrt}'."
    hrt = human_readable_time 60 * 60
    e = '1 h'
    assert e == hrt, "Expected '#{e}' but got '#{hrt}'."
    hrt = human_readable_time 60 * 90
    e = '1 h, 30 m'
    assert e == hrt, "Expected '#{e}' but got '#{hrt}'."
    hrt = human_readable_time 60 * 60 * 36
    e = '1 d, 12 h'
    assert e == hrt, "Expected '#{e}' but got '#{hrt}'."
  end

  # when these methods work copy them to the helpers.
  def human_readable_time(seconds)
    minutes = seconds.divmod(60)[0] # discard seconds.
    hours, minutes = minutes.divmod(60)
    days, hours= hours.divmod(24)
    result = ''
    result << "#{days} d, " if days > 0
    result << "#{hours} h, " if hours > 0
    result << "#{minutes} m," if minutes > 0
    return result.strip.chomp ','
  end

end
