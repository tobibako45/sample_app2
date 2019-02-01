require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  # app/helpers/sessions_helperのテスト
  # 永続的セッションのテスト

  def setup
    @user = users(:michael)
    remember(@user)
  end


  # sessionがnilのときcurrent_userは正しいユーザを返す
  test "current_user returns right user when session is nil" do
    # @userとcurrent_userが等しいか確認
    assert_equal @user, current_user
    # テストユーザーがログイン中か確認
    assert is_logged_in?
  end

  # ダイジェストが間違っていることを覚えているとcurrent_userはnilを返す
  test "current_user returns nil when remember digest is wrong" do

    # @userのremember_digestを、User.digest(User.new_token)で作ったランダムなハッシュ値をいれて更新する
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    # current_userか確認
    assert_nil current_user

  end





end
