class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # helpers/sessions_helper.rbを読み込み。全体で使えるように。
  include SessionsHelper


  def hello
    render html: "hello, world!"
  end


  private

  # users_controllerから移動してきた(Micropostsコントローラでも必要だから)
  # ログイン済みユーザーかどうか確認
  def logged_in_user
    # ユーザーがログインしていなければ
    unless logged_in?
      # アクセスしようとしたURLを覚えておく
      store_location
      flash[:danger] = "Please log in. ログインして下さい。"
      # ログインページへリダイレクト
      redirect_to login_url
    end
  end



end
