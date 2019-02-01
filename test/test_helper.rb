ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # app/helpers/application_helper.rbを呼び出し
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
  # すべてのテストで使用されるヘルパーメソッドをここに追加


  # テストユーザーがログイン中の場合にtrueを返す。
  # session_helperのlogged_in?メソッドと役割は一緒。こっちはテスト用
  def is_logged_in?
    !session[:user_id].nil?
  end

  # テストユーザーとしてログイン
  # session_helperのlog_in?メソッドと役割は一緒。こっちはテスト用
  def log_in_as(user)
    session[:user_id] = user.id
  end

end


# 統合テスト用クラス
class ActionDispatch::IntegrationTest

  # テストユーザーとしてログインする。remember_meにチェックがある状態
  def log_in_as(user, password: 'password', remember_me: '1')
    # 合テストではsessionを直接取り扱うことができないので、
    # 代わりにSessionsリソースに対してpostを送信することで代用
    post login_path, params: {
        session: {
            email: user.email,
            password: password,
            remember_me: remember_me
        }
    }
  end

end


# 単体テストか統合テストかを意識せずに、ログイン済みの状態をテストしたい時は、
# log_in_asをただ呼び出せば良い。ダッグタイピング