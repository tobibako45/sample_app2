require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  # アカウント有効化のテスト
  test "account_activation" do
    # テストユーザーをfixtureからmichaelを取得
    user = users(:michael)
    # テストユーザーの有効化トークンを生成する
    user.activation_token = User.new_token
    # Userメイラーのアカウント有効化処理にテストユーザー情報を渡して、メールオブジェクトを作成する
    mail = UserMailer.account_activation(user)
    # メールオブジェクトの件名をチェックする
    assert_equal "Account activation", mail.subject
    # メールオブジェクトの送信先メールアドレスをチェックする
    assert_equal [user.email], mail.to
    # メールオブジェクトの送信元メールアドレスをチェックする
    assert_equal ["noreply@example.com"], mail.from
    # テストユーザーの名前が、メールの本文に含まれているかチェックする
    assert_match user.name, mail.body.encoded
    # テストユーザーの有効化トークンが、メールの本文に含まれているかチェックする
    assert_match user.activation_token, mail.body.encoded
    # テストユーザーのアドレスがエスケープされて、メールの本に含まれているかチェックする
    assert_match CGI.escape(user.email), mail.body.encoded
  end


  # パスワード再設定用メイラーメソッドのテスト
  test "password_reset" do
    # テストユーザーをセット
    user = users(:michael)
    # テストユーザーのパスワード再設定トークンを生成
    user.reset_token = User.new_token
    # パスワード再設定メールを送信
    mail = UserMailer.password_reset(user)
    # mail.subjectと"Password reset"が一致するかチェック
    assert_equal "Password reset", mail.subject
    # mail.toと[user.email]が一致するかチェック
    assert_equal [user.email], mail.to
    # mail.formと["noreply@example.com"]が一致するかチェック
    assert_equal ["noreply@example.com"], mail.from
    # テストユーザのパスワード再設定トークンが、エンコードされたメール本文内に存在するかチェック
    assert_match user.reset_token,        mail.body.encoded
    # テストユーザのアドレスがエスケープされて、エンコードされたメール本文に含まれているかチェックする
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

end
