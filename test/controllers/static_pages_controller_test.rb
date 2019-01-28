require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  # assert_select(selector, equality?, message?)
  # アクション実行の結果として描写されるHTMLの内容を検証

  def setup
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  # test "should get root" do
  #   get root_url
  #   assert_response :success
  # end


  # GETリクエストで、homeページが200かチェック
  test "should get home" do
    # GETリクエストで送信
    # get static_pages_home_url
    get root_path # 名前付きルートに変更
    # ステータスコード 200
    assert_response :success
    # タイトルにこれが表示してるかチェック
    assert_select "title", "#{@base_title}"
  end

  # GETリクエストで、helpページが200かチェック
  test "should get help" do
    # get static_pages_help_url
    get help_path
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  # GETリクエストで、aboutページが200かチェック
  test "should get about" do
    # get static_pages_about_url
    get about_path
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end


  # GETリクエストで、contactページがあるか
  test "should get contact" do
    # get static_pages_contact_url
    get contact_path
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end


end
