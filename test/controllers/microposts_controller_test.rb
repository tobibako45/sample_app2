require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest


  def setup
    # micropostsのfixtureからorangeを取得して、インスタンス変数@micropostに代入する
    @micropost = microposts(:orange)
  end

  # ログイン時にcreateにリダイレクトする
  test "should redirect create when logged in" do
    # Micropostモデルの数をカウントし、数が変化していないこと
    assert_no_difference 'Micropost.count' do
      # microposts_pathにPOSTリクエストを送信。
      post microposts_path, params: {
          micropost: {
              content: "Lorem ipsum"
          }
      }
    end
    # ログイン画面にリダイレクト
    assert_redirected_to login_url
  end


  # ログインしていないときはdestroyにリダイレクトする
  test "should redirect destroy when not logged in" do
    # Micropostモデルの数をカウントし、数が変化していないこと
    assert_no_difference 'Micropost.count' do
      # microposts_pathにdeleteリクエストを送信
      delete micropost_path(@micropost)
    end
    # ログイン画面にリダイレクト
    assert_redirected_to login_url
  end


  # 間違ったユーザーによるマイクロポストの削除に対してリダイレクトする
  test "should redirect destroy for wrong micropost" do
    # michaelでログイン
    log_in_as(users(:michael))
    # マイクロポストのfixtureのantsを取得。(archer)のマイクロポスト
    micropost = microposts(:ants)
    # マイクロポストの数が変わらないことをチェック
    assert_no_difference 'Micropost.count' do
      # マイクロポストを削除する
      delete micropost_path(micropost)
    end
    # root_urlにリダイレクトすることをチェック
    assert_redirected_to root_url
  end


end
