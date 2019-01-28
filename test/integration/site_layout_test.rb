require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  # assert_select
  # アクション実行の結果として描写されるHTMLの内容を検証


  # サイトのレイアウトのリンクに対する統合テスト。

  test "layout links" do
    # root_pathにGETリクエストを送信
    get root_path
    # views/static_pages/home.html.erbが表示されているか確認
    assert_template 'static_pages/home'

    # aタグのリンクが、root_pathであることを確認。2個あることを。
    assert_select "a[href=?]", root_path, count: 2

    # aタグのリンクが、help_pathであることを確認。
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path

    # full_titleヘルパーを使う。app/helpers/application_helper.erbから

    # contact_pathにGETリクエストを送信
    get contact_path
    # ページのタイトルが、「Contact | Ruby on Rails Tutorial Sample App」であることを確認。
    assert_select "title", full_title("Contact")

    # signup_pathにGETリクエスト
    get signup_path
    # ページのタイトルが、「Sign up | Ruby on Rails Tutorial Sample App」であることを確認。
    assert_select "title", full_title("Sign up")

  end

end
