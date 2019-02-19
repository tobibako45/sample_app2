class UsersController < ApplicationController
  # before_action 処理が実行される直前に、特定のメソッドを実行する。

  # editとupdateだけ、先にlogged_in_userを実行
  # ログインしないでアクセスした時
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]

  # editとupdateだけ、正しいユーザーかどうか確認
  before_action :correct_user, only: [:edit, :update]

  # destroyの時は、現在のユーザーが管理者かチェック
  before_action :admin_user, only: :destroy


  def index
    # ユーザー全件
    # @users = User.all

    # ページネーション
    # @users = User.paginate(page: params[:page])

    # アカウントが有効なユーザーだけ
    @users = User.where(activated: true).paginate(page: params[:page])
  end


  def show
    @user = User.find(params[:id])
    # アカウントが有効なユーザーだけ表示、他はroot_urlにリダイレクト
    # redirect_to root_url and return unless @user.activated?

    @microposts = @user.microposts.paginate(page: params[:page])
    # debugger
  end

  def new
    @user = User.new
    # debugger
  end

  def create
    # @user = User.new(params[:user])
    # Strong Parametersで、指定した属性意外は許可しない
    @user = User.new(user_params)

    if @user.save
      # アカウント有効化前

      # 登録したらログインさせる
      # log_in @user
      # flash[:success] = 'Welcome to the Sample App'
      # redirect_to user_url(@user) # 下と同じ。railsが推察してやってくれる
      # redirect_to @user

      # アカウント有効化メールを送信。deliver_nowは、メールを送信するメソッド。
      # UserMailer.account_activation(@user).deliver_now
      # 上をモデルにメソッド化
      @user.send_activation_email

      flash[:info] = "Please check your email to activate your account. アカウントを有効にするには、メールを確認してください"
      # 有効化メールの送信後、root_urlにリダイレクト
      redirect_to root_url
    else
      render 'new'
    end

  end


  def edit
    @user = User.find(params[:id])
  end


  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end


  def destroy
    # DBから検索して削除
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    # ユーザー一覧にリダイレクト
    redirect_to users_url
  end


  private


  # Strong Parameters
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end


  # application_controllerから移動する(Micropostsコントローラでも必要だから)

  # ログイン済みユーザーかどうか確認
  # def logged_in_user
  #   # ユーザーがログインしていなければ
  #   unless logged_in?
  #     # アクセスしようとしたURLを覚えておく
  #     store_location
  #     flash[:danger] = "Please log in. ログインして下さい。"
  #     # ログインページへリダイレクト
  #     redirect_to login_url
  #   end
  # end


  # 正しいユーザーかどうか確認
  def correct_user
    # params[:id]でユーザーを検索して代入
    @user = User.find(params[:id])

    # @userとcurrent_userが違うなら、root_urlにリダイレクト
    # redirect_to(root_url) unless @user == current_user

    # 上のリファクタリング
    redirect_to(root_url) unless current_user?(@user)
  end


  # 管理者かどうか確認
  def admin_user
    # 現在のユーザーが管理者じゃなかったら、root_urlにリダイレクト
    redirect_to(root_url) unless current_user.admin?
  end


end
