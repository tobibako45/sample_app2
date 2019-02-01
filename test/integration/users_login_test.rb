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
  # 有効な情報でログインし、その後ログアウトする
  test "login with valid information followed by logout" do

    # GETリクエストでlogin_pathにアクセス
    get login_path
    # POSTリクエストで、loginにsession情報を送信。ログインする。
    post login_path, params: {
        session: {
            email: @user.email,
            password: 'password'
        }
    }
    # ログインできたか確認
    assert is_logged_in?
    # リダイレクト先が正しいか確認
    assert_redirected_to @user
    # 上で指定されたリダイレクト先に移動する
    follow_redirect!
    # ユーザー詳細ページが表示されているか確認
    assert_template 'users/show'
    # HTMLにログインリンクがないか確認（0件か）
    assert_select "a[href=?]", login_path, count: 0
    # HTMLにログアウトリンクがあるか確認
    assert_select "a[href=?]", logout_path
    # HTMLにユーザー詳細へのリンクがある確認
    assert_select "a[href=?]", user_path(@user)
    # DELETEリクエスト。ログアウト
    delete logout_path
    # ログインしていないか確認。ログアウトできたか。
    assert_not is_logged_in?
    # リダイレクト先が正しいか確認
    assert_redirected_to root_url

    # 2番目のウィンドウでログアウトをクリックするユーザーをシュミレートする

    # DELETEリクエスト。ログアウト
    delete logout_path
    # 上で指定されたリダイレクト先に移動する
    follow_redirect!
    # HTMLにログインリンクがあるか確認
    assert_select "a[href=?]", login_path
    # HTMLにログアウトリンクがないか確認（0件か）
    assert_select "a[href=?]", logout_path, count: 0
    # HTMLにユーザー詳細へのリンクがないか確認（0件か）
    assert_select "a[href=?]", user_path(@user), count: 0

  end






  # [remember me] チェックボックスのテスト

  # remember_tokenがnilではないことを確認
  test "login with remembering" do
    # テストユーザーとしてログイン。remember_meにチェックがある状態
    log_in_as(@user, remember_me: '1')

    # cookies['remember_token']が、nilでないかを確認
    # assert_not_empty cookies['remember_token']
    #
    # assignsメソッドを使わなかった場合


    # cookies['remember_token']とremember_tokenが等しいか確認
    assert_equal cookies['remember_token'], assigns(:user).remember_token
    # createアクションで@userというインスタンス変数が定義されていれば、
    # テスト内部ではassigns(:user)と書くことでインスタンス変数にアクセスできます。

  end


  # remember_tokenがnilであることを確認
  test "login without remembering" do
    # テストユーザーとしてログイン。remember_meにチェックがある状態
    log_in_as(@user, remember_me: '1')
    # DELETEリクエスト。ログアウト
    delete logout_path
    # テストユーザーとしてログイン。remember_meにチェックが無い状態
    log_in_as(@user, remember_me: '0')
    # cookies['remember_token']が、nilかを確認
    assert_empty cookies['remember_token']
  end


end
