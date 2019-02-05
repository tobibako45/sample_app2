require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  # サイトのレイアウトのリンクに対する統合テスト。


  # テストユーザー
  def setup
    @user = users(:michael)
  end

  # レイアウトリンクのチェック
  test "layout links" do
    # root_pathにGETリクエストを送信
    get root_path
    # views/static_pages/home.html.erbが表示されているか確認
    assert_template 'static_pages/home'

    # aタグのリンクが、root_pathが2個あることを確認。
    assert_select "a[href=?]", root_path, count: 2

    # aタグのリンクが、help_pathがあることを確認。
    assert_select "a[href=?]", help_path
    # aタグのリンクが、about_pathがあることを確認。
    assert_select "a[href=?]", about_path
    # aタグのリンクが、contact_pathがあることを確認。
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


  # ログイン時のレイアウトリンクのチェック
  test "layout links when logged in user" do
    # テストユーザーでログイン
    log_in_as(@user)
    # GETリクエストでroot_pathへアクセス
    get root_path
    # static_pages#homeのビューが表示されるか確認
    assert_template 'static_pages/home'
    # root_pathのリンクが2個あるか
    assert_select 'a[href=?]', root_path, count: 2
    # helpのリンクがあるか
    assert_select 'a[href=?]', help_path
    # ユーザー一覧のリンクがあるか
    assert_select 'a[href=?]', users_path
    # aboutのリンクがあるか
    assert_select 'a[href=?]', about_path
    # contactのリンクがあるか
    assert_select 'a[href=?]', contact_path
  end

end
