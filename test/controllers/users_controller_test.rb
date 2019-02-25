require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  # ログインしていない時、indexにリダイレクトする
  test "should redirect index when not logged in" do
    # GETリクエスト送信。/users(users#index)
    get users_path
    # ログインページにリダイレクトするか確認
    assert_redirected_to login_url
  end


  test "should get new" do
    # GETリクエスト送信。/signup(users#new)
    get signup_path
    # レスポンスが成功したかを検証
    assert_response :success
  end


  # ログインしていない時は、編集ページにリダイレクトする
  test "should redirect edit when not logged in" do
    # GETリクエスト送信。/users/:id/edit(users#edit)
    get edit_user_path(@user)
    # flashメッセージが空でないことをチェック
    assert_not flash.empty?
    # ログインページにリダイレクト
    assert_redirected_to login_url
  end

  # ログインしていない時は、アップデートにリダイレクトする
  test "should redirect update when not logged in" do
    # PATCHリクエスト送信(ユーザー情報を送信)。/users/:id(users#update)
    # @userの名前、emailを更新する
    patch user_path(@user),
          params: {
              user: {
                  name: @user.name,
                  email: @user.email
              }
          }

    # flashメッセージが空でないことをチェック
    assert_not flash.empty?
    # ログインページにリダイレクト
    assert_redirected_to login_url
  end


  # 間違ったユーザーとしてログインした場合は、編集ページからリダイレクトするべき
  test "should redirect edit when logged in as wrong user" do
    # other_userでログイン
    log_in_as(@other_user)
    # GETリクエスト送信。/users/:id/edit(users#edit)
    get edit_user_path(@user)
    # flashメッセージが空なとこを確認
    assert flash.empty?
    # root_urlへリダイレクト
    assert_redirected_to root_url
  end


  # 間違ったユーザーとしてログインした場合は、updateからリダイレクトするべき
  test "should redirect update when logged in as wrong user" do
    # other_userでログイン
    log_in_as(@other_user)
    # PATCHリクエスト送信(ユーザー情報を送信)。/users/:id(users#update)
    # @userの名前、emailを更新する
    patch user_path(@user), params: {
        user: {
            name: @user.name,
            email: @user.email
        }
    }
    # flashメッセージが空なことを確認
    assert flash.empty?
    # root_urlにリダイレクト
    assert_redirected_to root_url
  end


  # admin属性をWeb経由で編集することを許可しない
  test "should not allow the admin attribute to be edited via the web" do
    # other_userでログイン
    log_in_as(@other_user)
    # @other_userがtrue(管理者)でないことを確認
    assert_not @other_user.admin?
    # PATCHリクエスト送信(ユーザー情報を送信)。/users/:id(users#update)
    # @other_userのパスワード、パスワード確認、管理ユーザ属性を更新する
    patch user_path(@other_user), params: {
        user: {
            password: @other_user.password,
            password_confirmation: @other_user.password_confirmation,
            admin: true
        }
    }
    # @other_userの情報を再読み込みした結果、管理者ではないこと
    assert_not @other_user.reload.admin?
  end


  # ログインしていないときはdestroyにリダイレクトするべき
  test "should redirect destroy when not logged in" do
    # ユーザー数が変わっていないか確認
    assert_no_difference 'User.count' do
      # DELETEリクエスト送信。/users/:id(users#destroy)
      delete user_path(@user)
    end
    # ログイン画面にリダイレクト
    assert_redirected_to login_url
  end


  # 非管理者としてログインした場合はリダイレクトされる
  test "should redirect when logged in as a non-admin" do
    # @other_user（非管理）でログイン
    log_in_as(@other_user)
    # ユーザー数が変わっていないか確認
    assert_no_difference 'User.count' do
      # DELETEリクエスト送信。/users/:id(users#destroy)
      delete user_path(@user)
    end
    # root_url(static_pages#home)にリダイレクト
    assert_redirected_to root_url
  end


  # followingページには、ログインしていないときはログインページにリダイレクトされること
  test "should redirect following when not logged in" do
    # GETリクエスト送信。/users/:id/following(users#following)
    get following_user_path(@user)
    # login_url(sessions#new)にリダイレクトされること
    assert_redirected_to login_url
  end

  # followersページには、ログインしていないときはログインページにリダイレクトされること
  test "should redirect followers when not logged in" do
    # GETリクエスト送信。/users/:id/followers(users#followers)
    get followers_user_path(@user)
    # login_url(sessions#new)にリダイレクトされること
    assert_redirected_to login_url
  end

end
