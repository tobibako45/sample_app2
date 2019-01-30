require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest


  def setup
    @user = users(:michael)
  end


  # invalidな情報でログイン
  test "login with invalid information" do
    # ログイン用パスを開く
    get login_path
    # 新しいsessionのフォームが表示されているか確認
    assert_template 'sessions/new'
    # 無効なparamsを、POST送信
    post login_path, params: {
        session: {
            email: "",
            password: ""
        }
    }
    # ログインフォームが表示されているか
    assert_template 'sessions/new'
    # flashメッセージが追加されているか
    assert_not flash.empty?
    # 別のページにいったん移動
    get root_path
    # flashメッセージが表示されていないか
    assert flash.empty?
  end


  # 有効な情報でログイン
  test "login with valid information" do
    # ログイン用のパスを開く
    get login_path
    # セッション用パスに有効な情報をPOSTする。ログイン
    post login_path, params: {
        session: {
            email: @user.email,
            password: "password"
        }
    }

    # リダイレクト先が正しいかどうかをチェック
    assert_redirected_to @user

    # そのページに実際に移動
    # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    follow_redirect!

    # ログイン用リンクが表示されなくなったことを確認
    assert_select "a[href=?]", login_path, count: 0
    # ログアウト用リンクが表示されていることかを確認
    assert_select "a[href=?]", logout_path
    # プロフィール用リンク(show)が表示されているか確認
    assert_select "a[href=?]", user_path(@user)

  end


  # ユーザーログアウトのテスト
  test "login with valid information followed by logout" do
    # GETリクエストでloginにアクセス
    get login_path
    # POSTリクエストでloginにユーザー情報を送信。ログインする。
    post login_path, params: {
        session: {
            email: @user.email,
            password: 'password'
        }
    }
    # ログインできたか確認
    assert is_logged_in?
    # リダイレクト先が正しいかどうかをチェック
    assert_redirected_to @user
    # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    follow_redirect!

    # users/showのテンプレートが表示されているか確認
    assert_template 'users/show'
    # ログインのリンクがないか確認
    assert_select "a[href=?]", login_path, count: 0
    # ログアウトのリンクがあるか確認
    assert_select "a[href=?]", logout_path
    # ユーザー詳細へのリンクがあるか確認
    assert_select "a[href=?]", user_path(@user)
    # DELETEリクエスト。ログアウト
    delete logout_path
    # ログインしていないか確認。ログアウトできたか。
    assert_not is_logged_in?
    # リダイレクト先がroot_urlか
    assert_redirected_to root_url
    # 上のリンクにちゃんと飛んだか
    follow_redirect!
    # ログインリンクがあるか
    assert_select "a[href=?]", login_path
    # ログアウトリンクがないか
    assert_select "a[href=?]", logout_path, count: 0
    # ユーザー詳細へのリンクがないか
    assert_select "a[href=?]", user_path(@user), count: 0
  end


end
