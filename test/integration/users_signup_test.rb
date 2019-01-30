require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest


  # 無効なユーザー登録に対するテスト
  test "invalid signup information" do

    # signup_pathにGETリクエスト
    get signup_path

    # User.countが変わっていなければ成功
    assert_no_difference 'User.count' do
      # POSTリクエスト送信（POSTなのでcreateアクションに）
      post signup_path, params: {
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
    assert_select 'form[action="/signup"]'

  end

  # 有効なユーザー登録に対するテストgreen
  test "valid signup information" do
    # GETリクエストを送信
    get signup_path

    # assert_differenceブロック内の処理を実行する直前と、
    # 実行した直後のUser.countの値を比較します。
    # 第二引数はオプションですが、
    # ここには比較した結果の差異 (今回の場合は1) を渡します。
    assert_difference 'User.count', 1 do

      post users_path, params: {
          user: {
              name: "Example User",
              email: "user@example.com",
              password: "password",
              password_confirmation: "password"
          }
      }
    end

    # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    # 'users/showのテンプレートが表示されているか。
    assert_template 'users/show'
    # flashメッセージが空でないことを確認
    assert_not flash.empty?
  end


end
