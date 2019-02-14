require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest


  def setup
    # 配信方法が:testの場合、メールを保存する配列をクリアする
    ActionMailer::Base.deliveries.clear
    # michaelの情報を取得し、インスタンス変数@userに格納
    @user = users(:michael)
  end

  # パスワード再設定の統合テスト
  test "password resets" do
    # new_password_reset_path(Forgot password)画面にGETリクエスト送信
    get new_password_reset_path
    # password_resetsのnew.html.erbが表示されているかチェック
    assert_template 'password_resets/new'

    # メールアドレスが無効の場合

    # password_resets_path(createアクション)にPOST送信。メールアドレスはブランク(空)
    post password_resets_path, params: {
        password_reset: {
            email: ""
        }
    }
    # flashメッセージが空でないことをチェック
    assert_not flash.empty?
    # Forgot password(new.html)が表示されているかチェック
    assert_template 'password_resets/new'

    # メールアドレスが有効の場合

    # password_resets_path(createアクション)にPOST送信。メールアドレスは@user.email
    post password_resets_path, params: {
        password_reset: {
            email: @user.email
        }
    }
    # @userのreset_digestが、リロード前と後で一致しないかチェック（変更されているか）
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # メイラーの配列に保存された件数が１件であること
    assert_equal 1, ActionMailer::Base.deliveries.size
    # flashメッセージが空でないこと
    assert_not flash.empty?
    # root_urlにれダイレクト
    assert_redirected_to root_url


    # パスワード再設定フォームのテスト

    # アクション内で設定されたインスタンス変数を検証
    # assignsメソッドはコントローラーのインスタンス変数をテストするメソッドです。
    # 引数にインスタンス変数をシンボル型で渡します。
    user = assigns(:user)


    # メールアドレスが無効の場合

    # edit_password_reset_path(editアクション)にGET送信。userのリセットトークン(user.reset_token)とメールアドレス(空)
    get edit_password_reset_path(user.reset_token, email: "")
    # root_urlにリダイレクト
    assert_redirected_to root_url


    # 無効なユーザーの場合

    # userの有効化フラグ(activated)を逆転。
    user.toggle!(:activated)
    # edit_password_reset_path(editアクション)にGET送信。userのリセットトークン(user.reset_token)とメールアドレス
    get edit_password_reset_path(user.reset_token, email: user.email)
    # root_urlにリダイレクト
    assert_redirected_to root_url
    # userの有効化フラグ(activated)を戻す。
    user.toggle!(:activated)


    # メールアドレスが有効で、トークンが無効

    # edit_password_reset_path(editアクション)にGET送信。userのリセットトークン(wrong token)とメールアドレス
    get edit_password_reset_path('wrong token', email: user.email)
    # root_urlにリダイレクト
    assert_redirected_to root_url


    # メールアドレスもトークンの有効

    # edit_password_reset_path(editアクション)にGET送信。userのリセットトークン(user.reset_token)とメールアドレス
    get edit_password_reset_path(user.reset_token, email: user.email)

    # パスワード再設定画面が表示されているか
    assert_template 'password_resets/edit'
    # HTMLに、input属性、name:email、type:hidden、value:user.emailが表示されているかチェック
    assert_select "input[name=email][type=hidden][value=?]", user.email


    # 無効なパスワードとパスワード確認

    # password_reset_path(updateアクション)にPATCHリクエスト送信
    patch password_reset_path(user.reset_token),
          params: {
              email: user.email,
              user: {
                  password: "foobaz",
                  password_confirmation: "barquux"
              }
          }
    # HTMLに、div error_explanationが表示されている。（エラー）
    assert_select 'div#error_explanation'


    # 空のパスワード

    # password_reset_path(updateアクション)にPATCHリクエスト送信
    patch password_reset_path(user.reset_token),
          params: {
              email: user.email,
              user: {
                  password: "",
                  password_confirmation: ""
              }
          }
    # HTMLに、div error_explanationが表示されている。（エラー）
    assert_select 'div#error_explanation'


    # 有効なパスワードとパスワード確認

    # password_reset_path(updateアクション)にPATCHリクエスト送信
    patch password_reset_path(user.reset_token),
          params: {
              email: user.email,
              user: {
                  password: "foobaz",
                  password_confirmation: "foobaz"
              }
          }

    # テストユーザーがログイン中であるかチェック
    assert is_logged_in?
    # flashメッセージが空でないこと
    assert_not flash.empty?
    # ユーザー詳細にリダイレクト
    assert_redirected_to user
  end


  # パスワード再設定の期限切れのテスト
  test "expired token" do
    # new_password_reset_path(newアクション)にGETリクエストを送信
    get new_password_reset_path
    # password_resets_path（createアクション）にPOST送信
    post password_resets_path,
         params: {
             password_reset: {
                 email: @user.email
             }
         }
    # パスワード再設定フォームのテストのために、アクションを実行結果、インスタンス変数に代入されたオブジェクトを取得
    @user = assigns(:user)
    # reset_sent_at(パスワード再設定メールの送信時間)を３時間前に更新する
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    # password_reset_path(updateアクション)にPATCH送信。有効な情報。
    patch password_reset_path(@user.reset_token),
          params: {
              email: @user.email,
              user: {
                  password: "foobar",
                  password_confirmation: "foobar"
              }
          }
    # レスポンスが302である
    assert_response :redirect
    # 単一のリダイレクトのレスポンスに従う
    follow_redirect!
    # レスポンスで返されたHTMLの中身に、expired（期限切れ）の文字列が存在すること
    assert_match /expired/i, response.body
  end


end
