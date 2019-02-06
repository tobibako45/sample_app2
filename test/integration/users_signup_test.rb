require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest


  # 配列deliveriesを初期化する
  def setup
    ActionMailer::Base.deliveries.clear
  end



  # 無効なユーザー登録に対するテスト
  test "invalid signup information" do
    # signup_pathにGETリクエスト
    get signup_path
    # User.countが変わっていなければ成功
    assert_no_difference 'User.count' do
      # POSTリクエスト送信（POSTなのでcreateアクションに）
      post users_path, params: {
          user: {
              name: "",
              email: "user@invalid",
              password: "foo",
              password_confirmation: "bar"
          }
      }
    end
    # users/newのテンプレートが描写されているかチェック
    assert_template 'users/new'
    # div#error_explanationが描写されているかを確認
    assert_select 'div#error_explanation'
    # div.alertが描写されているかをチェック
    assert_select 'div.alert'

    # form[action="/signup"]が描写されているかを確認
    # assert_select 'form[action="/signup"]'

    # 上をusers#newへ変更
    assert_select 'form[action="/users"]'
  end



  # 有効なユーザー登録に対するテストに、アカウント有効化を追加
  # test "valid signup information" do
  test "valid signup information with account activation" do

    # GETリクエストを送信
    get signup_path
    # assert_differenceブロック内の処理を実行する直前と、
    # 実行した直後のUser.countの値を比較します。
    # 第二引数はオプションですが、
    # ここには比較した結果の差異 (今回の場合は1) を渡します。
    assert_difference 'User.count', 1 do
      # POSTリクエスト送信（POSTなのでcreateアクションに）
      post users_path, params: {
          user: {
              name: "Example User",
              email: "user@example.com",
              password: "password",
              password_confirmation: "password"
          }
      }
    end

    # 配信されたメッセージが1と等しいか確認
    assert_equal 1, ActionMailer::Base.deliveries.size

    # createアクション内のインスタンス変数@userにアクセスしてユーザー情報を取得する
    # assigns(key = nil)	アクションを実行した結果、インスタンス変数に代入されたオブジェクトを取得
    user = assigns(:user)

    # ユーザーが有効化されていないことを確認
    assert_not user.activated?

    # 有効化していない状態でログインしてみる
    log_in_as(user)
    # ログインできないことを確認
    assert_not is_logged_in?

    # 有効化トークンが不正な場合。
    get edit_account_activation_url("invalid token", email: user.email)
    # ログインできないことを確認
    assert_not is_logged_in?

    # トークンは正しいがメールアドレスが無効な場合。
    get edit_account_activation_url(user.activation_token, email: 'wrong')
    # ログインできないことを確認
    assert_not is_logged_in?

    # 有効化トークンがただしい場合。
    get edit_account_activation_url(user.activation_token, email: user.email)
    # ユーザーをDBから再読み込みして、有効化されていることを確認
    assert user.reload.activated?


    # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    # 'users/showのテンプレートが表示されているか。
    assert_template 'users/show'
    # flashメッセージが空でないことを確認
    assert_not flash.empty?
    # ユーザー登録後のログインしたかチェック
    assert is_logged_in?
  end


end
