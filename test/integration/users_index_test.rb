require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest


  def setup
    # @user = users(:michael)
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  # ページネーションを含めたuser#indexのテスト
  # test "index including pagination" do
  #   # テストユーザーでログインする
  #   log_in_as(@user)
  #   # ユーザー一覧へアクセス
  #   get users_path
  #   # ユーザー一覧のビューテンプレートが表示されているかチェック
  #   assert_template 'users/index'
  #   # HTMLにdiv.paginateが、2個あるかチェック
  #   assert_select 'div.pagination', count: 2
  #   # 1ページ目にユーザーが存在することを確認
  #   User.paginate(page: 1).each do |user|
  #     # user.nameがテキストで表示されていて、詳細ページへのリンクになっているか確認
  #     assert_select 'a[href=?]', user_path(user), text: user.name
  #   end
  # end


  # 削除リンクとユーザー削除に対するテスト
  # ページ区切りを含む管理者としてのインデックスとリンクの削除
  test "index as admin including pagination and delete links" do
    # テストユーザーでログインする
    log_in_as(@admin)
    # ユーザー一覧へアクセス
    get users_path
    # ユーザー一覧のビューテンプレートが表示されているかチェック
    assert_template 'users/index'
    # HTMLにdiv.paginateが、2個あるかチェック
    assert_select 'div.pagination', count: 2

    # １ページ目のユーザー（30ユーザー）を取得
    first_page_users = User.paginate(page: 1)
    # 30ユーザーをループ
    first_page_users.each do |user|
      # ユーザー名とユーザーページへのリンク属性が表示されること
      assert_select 'a[href=?]', user_path(user), text: user.name
      # 管理者ユーザーでなければ、deleteリンクが表示されること
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    # ユーザーの件数が-1されていること
    assert_difference 'User.count', -1 do
      # DELETEリクエストを非管理者ユーザーに送信
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    # 非管理者ユーザーでログインする
    log_in_as(@non_admin)
    # ユーザー一覧にアクセス
    get users_path
    # HTMLにaタグと、deleteのテキストが表示されないこと
    assert_select 'a', text: 'delete', count: 0
  end



end
