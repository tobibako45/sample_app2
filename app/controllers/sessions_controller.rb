class SessionsController < ApplicationController
  def new

  end

  def create
    # Userからemailで検索
    user = User.find_by(email: params[:session][:email].downcase)
    #
    if user && user.authenticate(params[:session][:password])
      # ユーザーにログインする
      log_in user
      # user_url(user)同じ。すなわち、ユーザー詳細(show)にリダイレクト
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination　無効なメールアドレスとパスワードの組み合わせ' # 本当は正しくない
      render 'new'
    end
  end


  def destroy
    # ログアウト
    log_out
    # root_urlにリダイレクト
    redirect_to root_url
  end

end
