class PasswordResetsController < ApplicationController

  # before_action 処理が実行される直前に、特定のメソッドを実行する。

  # emailからユーザーを検索
  before_action :get_user, only: [:edit, :update]
  # 正しいユーザーかどうか確認する
  before_action :valid_user, only: [:edit, :update]
  # パスワード再設定の有効期限が切れていないか
  before_action :check_expiration, only: [:edit, :update]


  def new
  end


  def create
    # パスワード再設定メールのリンクに仕込んだemailアドレスから、ユーザーを検索する
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      # パスワード再設定の属性を設定する
      @user.create_reset_digest
      # パスワード再設定のメールを送信する
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions パスワード再設定の指示とともに送信されたEメール"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found メールアドレスが見つかりません"
      render 'new'
    end
  end


  def edit
  end


  def update
    if params[:user][:password].empty? # 新しいパスワードが空文字でないか
      # errors.add エラーメッセージを追加
      # パスワードが空だった時に空の文字列に対するデフォルトのメッセージを表示してくれる
      @user.errors.add(:password, :blank)
      # editページを描画
      render 'edit'
    elsif @user.update_attributes(user_params) # 新しいパスワードが正しければ更新する
      # ログインする
      log_in @user
      # パスワード再設定が成功したらダイジェストをnilにする。セキュリティ対策
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset.パスワードがリセットされました"
      # ユーザーページのにリダイレクト
      redirect_to @user
    else # 無効なパスワードであれば失敗させる
      # editページを描画
      render 'edit'
    end
  end


  private

  # Strong Parameters
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # before_action

  # emailからユーザーを検索
  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーかどうか確認する
  def valid_user
    # @userが「存在していて、有効で、認証済み(トークンがダイジェストと一致)」で無い場合
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  # トークンが期限切れかどうか
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired.パスワードのリセット期限が切れました"
      redirect_to new_password_reset_url
    end
  end


end
