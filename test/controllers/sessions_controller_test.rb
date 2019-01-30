require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest


  # Sessionsコントローラのテストで名前付きルートを使うようにする
  test "should get new" do
    # get sessions_new_url
    get login_path

    # レスポンスが成功したかを検証
    assert_response :success
  end

end
