require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  # 作成にはログインユーザーが必要
  test "create should require logged-in user" do
    # relationshipの数が変わらないことを確認
    assert_no_difference 'Relationship.count' do
      # POSTリクエスト送信。/relationships(relationships#create)
      post relationships_path
    end
    # ログイン画面にリダイレクトされること。/login(session#new)
    assert_redirected_to login_url
  end


  # 破棄するにはログインユーザーが必要
  test "destroy should require logged_in user" do
    # relationshipの数が変わらないことを確認
    assert_no_difference 'Relationship.count' do
      # DELETEリクエスト送信。/relationships(relationships#destroy)
      # fixtureのrelationship内の:oneを削除
      delete relationship_path(relationships(:one))
    end
    # ログイン画面にリダイレクトされること。/login(session#new)
    assert_redirected_to login_url
  end

end
