module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end


  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    # sessionに値がある時
    if session[:user_id]
      # @current_userが空の時は、Userから検索して代入。
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end


  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end


  # 現在のユーザーをログアウトする
  def log_out
    # sessionから、user_idを削除する
    session.delete(:user_id)
    # こっちもnilにする
    @current_user = nil
  end



end
