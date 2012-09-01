require 'koala'
require 'test-unit'
require './test/handler_test_base'

class TagTest < HandlerTestBase

  def test_tag_starts_with
    ActiveRecord::Base.transaction do |t|
      tt = Tag.create(:name => "this is a test")
      tr = Tag.name_starts_with('this').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'this', but got #{tr.name}"
      tr = Tag.name_starts_with('This').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'This' after lowercase conversion, but got #{tr.name}"
      tt..name = "This is a test"
      tt.save!
      
      tr = Tag.name_starts_with('this').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'this', but got #{tr.name}"
      tr = Tag.name_starts_with('This').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'This' after lowercase conversion, but got #{tr.name}"

      tr = Tag.name_starts_with("bingo").first
      assert tr == nil, "Expected no results."

      tt.destroy
    end
    assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag type#{Tag.count == 1 ? '' : 's'} left over."
  end

#   def test_tag_in_use
#     ActiveRecord::Base.transaction do |t|
#       tt = Tag.create(:name => "test tag 1")
#       assert Tag.in_use.empty?, "Expected no tags to be in use."
#     end
#   end

end
