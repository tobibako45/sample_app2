require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other = users(:archer)

    # michaelでログイン
    log_in_as(@user)
  end


  # followingページのテスト
  test "following page" do
    # GETリクエスト送信。/users/:id/following(users#following)
    get following_user_path(@user)
    # フォローユーザーが空でないことを確認
    assert_not @user.following.empty?
    # フォローユーザーの数がHTML内に存在するか確認
    assert_match @user.following.count.to_s, response.body
    # フォローユーザーの数だけループ
    @user.following.each do |user|
      # フォローユーザーの詳細ページへのリンクがあること。/users/:id(users#show)
      assert_select "a[href=?]", user_path(user)
    end
  end


  # followersページのテスト
  test "followers page" do
    # GETリクエスト送信。/users/:id/followers(users#followers)
    get followers_user_path(@user)
    # フォロワーユーザーが空でないか確認
    assert_not @user.followers.empty?
    # フォロワーユーザーの数がHTML内に存在しているか確認
    assert_match @user.followers.count.to_s, response.body
    # フォロワーの数だけループ
    @user.followers.each do |user|
      # フォロワーユーザーの詳細ページへのリンクがあること。/users/:id(users#show)
      assert_select "a[href=?]", user_path(user)
    end
  end


  # 標準的な方法でユーザーをフォロー
  test "should follow a user the standard way" do
    # @userのフォローが1増えていることを確認
    assert_difference '@user.following.count', 1 do
      # POSTリクエスト送信。/relarionships(relationships#create)
      # @otherをフォロー
      post relationships_path, params: {followed_id: @other.id}
    end
  end

  # Ajaxを使用してユーザーをフォロー
  test "should follow a user with Ajax" do
    # @userのフォローが1増えていることを確認
    assert_difference '@user.following.count', 1 do
      # Ajax版
      # POSTリクエスト送信。/relarionships(relationships#create)
      # @otherをフォロー
      post relationships_path, xhr: true, params: {followed_id: @other.id}
    end
  end

  # 標準的な方法でユーザーフォローを解除
  test "should unfollow a user the standard way" do
    # @userが@otherをフォローする
    @user.follow(@other)
    # @user.active_relationships（フォローしているユーザー）から、@other.idを検索する
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    # @userのフォローが1減っていることを確認
    assert_difference '@user.following.count', -1 do
      # DELETEリクエスト送信。/reationships/:id(relationships#destroy)
      # @otherをフォロー解除
      delete relationship_path(relationship)
    end
  end

  # Ajaxを使用してユーザーフォローを解除
  test "should unfollow a user with Ajax" do
    # @userが@otherをフォローする
    @user.follow(@other)
    # @user.active_relationships（フォローしているユーザー）から、@other.idを検索する
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    # @userのフォローが1減っていることを確認
    assert_difference '@user.following.count', -1 do
      # Ajax版
      # DELETEリクエスト送信。/relationships/:id(relationships#destroy)
      # @otherをフォロー解除
      delete relationship_path(relationship), xhr: true
    end
  end


end
