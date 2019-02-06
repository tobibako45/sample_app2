module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end


  # ユーザーのセッションを永続的にする(20.years.from_now)
  def remember (user)
    # 永続セッションのためにユーザーをデータベースに記憶する。modelのremember
    user.remember
    # user.idをに代入。permanentで期限20年。signedで署名付き。
    cookies.permanent.signed[:user_id] = user.id
    # user.remember_tokenを代入。modelのUser.rememberで代入した、変数remember_token。
    cookies.permanent[:remember_token] = user.remember_token
  end


  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end


  # 現在ログイン中のユーザーを返す

  # 現在ログイン中のユーザーを返す（いる場合）
  # def current_user
  #   # sessionに値がある時
  #   if session[:user_id]
  #     # @current_userが空の時は、Userから検索して代入。
  #     @current_user ||= User.find_by(id: session[:user_id])
  #   end
  # end

  # 上はsessionで一時保持だけ


  # 記憶トークンcookieに対応するユーザーIDを返す
  def current_user
    #  session[:user_id]に値がある場合
    if (user_id = session[:user_id])

      # session[:user_id]で検索して、@current_userが空の時は、Userから検索して代入。
      @current_user ||= User.find_by(id: user_id)

    elsif (user_id = cookies.signed[:user_id]) # cookies[:user_id]に値がある場合は、signedで取り出して

      # テストがパスすれば、この部分がテストされていないことがわかる
      # raise

      # cookies[:user_id]で検索
      user = User.find_by(id: user_id)

      # userがtrue、cookies[:remember_token]がremember_digestと一致したらtrue の場合
      # if user && user.authenticated?(cookies[:remember_token])

      # authenticated?の抽象化版
      if user && user.authenticated?(:remember, cookies[:remember_token])
        # ログインする
        log_in user
        # @current_userにuserを代入
        @current_user = user
      end

    end
  end


  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    # userモデルのforgetを呼んで、remember_digestの値をnilに更新
    # (byebug) userの中身を確認
    user.forget

    # cookies[:user_id]を破棄
    cookies.delete(:user_id)
    # cookies[:remember_token]を破棄
    cookies.delete(:remember_token)
  end


  # 現在のユーザーをログアウトする
  def log_out
    # 現在のユーザーの、cookies[:user_id]とcookies[:remember_token]を破棄、DBのremember_dogestをnilに更新。
    forget(current_user)

    # sessionから、user_idを削除する
    session.delete(:user_id)
    # こっちもnilにする
    @current_user = nil
  end


  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  # sessionコントローラのcreateアクションに追加
  def redirect_back_or(default)
    # 値がnilでなければsession[:forwarding_url]を評価し、そうでなければデフォルトのURL
    redirect_to(session[:forwarding_url] || default)
    # 次回ログインした時に備えて、転送用URLを削除する
    session.delete(:forwarding_url)
  end


  # アクセスしようとしたURLを覚えておく
  # usersコントロラーのlogged_in_userメソッドに追加。before_actionでログイン済みかチェックする時に。
  def store_location
    # GETリクエストの場合のみ、request.original_urlをsession変数の:forwarding_urlキーに格納する。（記憶しておく）
    session[:forwarding_url] = request.original_url if request.get?
  end

end
