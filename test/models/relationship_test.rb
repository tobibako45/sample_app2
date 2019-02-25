require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    # Relationshipモデルを生成。
    @relationship = Relationship.new(follower_id: users(:michael).id, followed_id: users(:archer).id)
  end

  # Relationshipモデルのバリデーションをテスト

  # 有効かチェック
  test "should be valid" do
    assert @relationship.valid?
  end

  # follower_idが有効かチェック
  test "should require a follower_id" do
    @relationship.follower_id = nil
    # @relationshipが有効ではないことをチェック
    assert_not @relationship.valid?
  end

  # followed_idが有効か
  test "should require a followed_id" do
    @relationship.followed_id = nil
    # @relationshipが有効ではないことをチェック
    assert_not @relationship.valid?
  end


  # following関連テスト
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    # michaelがarcherをフォローしていないことをチェック
    assert_not michael.following?(archer)
    # michaelがarcherをフォロー
    michael.follow(archer)
    # michaelがarcherをフォローしていることをチェック
    assert michael.following?(archer)
    # archerのフォロワーに、michaelが存在することをチェック
    # assert archer.followers.include?(michael)
    # michaelがarcherをフォロー解除
    michael.unfollow(archer)
    # michaelがarcherをフォローしていないことをチェック
    assert_not michael.following?(archer)
  end




end
