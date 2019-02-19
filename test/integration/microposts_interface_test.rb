require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end


  # マイクロポストのUIに対するテスト
  test "micropost interface" do
    # ログイン(michael)
    log_in_as(@user)
    # root_pathにGETリクエスト送信
    get root_path
    # HTMLにdiv.paginationが表示されているか
    assert_select 'div.pagination'

    # アップローダー追加後に追記
    # HTMLにinput type=fileがあるかチェック
    assert_select 'input[type=file]'

    # 無効な送信

    # マイクロポストの数が変わらないこと
    assert_no_difference 'Micropost.count' do
      # microposts_pathへPOST送信。contentは空
      post microposts_path, params: {
          micropost: {
              content: ""
          }
      }
    end
    # HTMLにdiv#error_explanationが表示されているか
    assert_select 'div#error_explanation'


    # 有効な送信

    # 文字列を代入
    content = "This micropost really ties the room together"

    # アップローダー追加後に追記
    # fixtureディレクトリにあるrails.pngを、image/pngにアップロードして、picture変数に代入
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')

    # マイクロポストの数が変わることをチェック。1ずつ増える。
    assert_difference 'Micropost.count', 1 do
      # microposts_path(createアクション)にPOST送信。contentに文字列。
      post microposts_path, params: {
          micropost: {
              content: content,
              picture: picture # アップローダー追加後に追記
          }
      }
    end
    # root_urlにリダイレクトするかチェック
    assert_redirected_to root_url
    # 上で指定されたリダイレクト先に移動する
    follow_redirect!
    # 代入したcontentの文字列が、HTML内に一致すること
    assert_match content, response.body


    # 投稿を削除する

    # HTML内にdeleteテキストとaタグがあることをチェック
    assert_select 'a', text: 'delete'
    # ユーザの1番目のマイクロポストを取得する
    first_micropost = @user.microposts.paginate(page: 1).first
    # マイクロポストの数が減っていることをチェック。-1ずつ。
    assert_difference 'Micropost.count', -1 do
      # micropost_path(deleteアクション) にPOST送信
      delete micropost_path(first_micropost)
    end

    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    get user_path(users(:archer))
    # HTML内にdeleteテキストとaタグが無いことをチェック
    assert_select 'a', text: 'delete', count: 0
  end


  # サイドバーにあるマイクロポストの合計投稿数をテスト
  test "micropost sidebar count" do
    # ログインする。(michael)
    log_in_as(@user)
    # root_pathへGET送信
    get root_path
    # sユーザのマイクロポスト数をカウントし、複数形で表示されることを確認
    assert_match "#{@user.microposts.count} microposts", response.body

    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    # maloryでログイン
    log_in_as(other_user)
    # root_pathへGET送信
    get root_path
    # HTMLに"0 micropost"と単数形で表示されることを確認
    assert_match "0 micropost", response.body
    # maloryユーザでマイクロポストを投稿する
    other_user.microposts.create!(content: "A micropost")
    # root_pathへGET送信
    get root_path
    # HTMLに"1 micropost"と単数形で表示されることを確認
    assert_match "1 micropost", response.body
  end

end
