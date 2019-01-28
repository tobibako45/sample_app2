require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  # app/helpers/application_helperのテスト

  test "full title helper" do
    # full_titleと、"Ruby on Rails Tutorial Sample App"が同じことを確認
    assert_equal full_title, "Ruby on Rails Tutorial Sample App"
    # full_titleと、"Help | Ruby on Rails Tutorial Sample App"が同じことを確認
    assert_equal full_title("Help"), "Help | Ruby on Rails Tutorial Sample App"
  end
end
