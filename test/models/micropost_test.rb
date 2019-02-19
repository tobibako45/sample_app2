require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)

    # このコードは慣習的に正しくない
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)

    # 慣習的に正しくマイクロポストを作成する
    @micropost = @user.microposts.build(content: "Loren ipsum")
  end


  # 新しいMicropostの有効性に対するテスト

  # 有効かどうか
  test "should be valid" do
    # @micropostが有効であるかチェック
    assert @micropost.valid?
  end

  # ユーザーIDが存在しているか(nilでないか)
  test "user id should be present" do
    # @micropostのuser_idにnilを代入
    @micropost.user_id = nil
    # @micropostが有効でないことをチェック
    assert_not @micropost.valid?
  end


  # Micropostモデルのバリデーションに対するテスト

  # contentが存在しているか
  test "content should be present" do
    # @micropostにcontentに、空文字を代入
    @micropost.content = "   "
    # @micropostが有効でないことチェック
    assert_not @micropost.valid?
  end


  # contentは最大140文字であるか
  test "content should be a most 140 characters" do
    # 141文字を代入
    @micropost.content = "a" * 141
    # @micropostが有効でないことをチェック
    assert_not @micropost.valid?
  end


  # 順番付けをテスト(降順)
  test "order should be recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end





end