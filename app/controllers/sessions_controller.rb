class SessionsController < ApplicationController

  def new
    # debugger
  end

  def create
    # Userからemailで検索
    @user = User.find_by(email: params[:session][:email].downcase)

    # userがtrue、@user.password_digestとparams[:session][:password]を比較した値がtrue な時
    if @user && @user.authenticate(params[:session][:password])

      # アカウントが有効かどうか
      if @user.activated?
        # ユーザーにログインする
        log_in @user
        # ログインしてユーザーを保持する

        # remember_meにチェックがはいっていたら、cookiesにuser_idとremember_tokenを記憶する
        # はいってなければ、cookiesを破棄（記憶しないようにする）
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        # ここでのrememberとforgetはhelperのやつ。
        # そこでmodelのrememberとforgetを実行している。
        # debugger

        # user_url(@user)同じ。すなわち、ユーザー詳細(show)にリダイレクト
        # redirect_to @user
        # 記憶したURL（もしくはデフォルト値）にリダイレクト（フレンドリーフォワーディング）
        redirect_back_or @user

      else
        # 有効でないユーザーがログインすることのないようにする

        message = "Account not activated. アカウントが有効になっていません。"
        message += "Check your email for the activation link.　アクティベーションリンクについては、メールを確認してください。"
        flash[:warning] = message
        redirect_to root_url
      end

    else
      flash.now[:danger] = 'Invalid email/password combination  無効なメールアドレスとパスワードの組み合わせ'
      render 'new'
    end
  end


  def destroy
    # ログアウト
    # log_out

    # ログイン中の場合のみログアウトする
    log_out if logged_in?

    # root_urlにリダイレクト
    redirect_to root_url
  end

end
