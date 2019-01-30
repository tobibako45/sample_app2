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

  # テストユーザーがログイン中の場合にtrueを返す。
  # session_helperのlogged_in?メソッドと役割は一緒。こっちはテスト用
  def is_logged_in?
    !session[:user_id].nil?
  end





end
