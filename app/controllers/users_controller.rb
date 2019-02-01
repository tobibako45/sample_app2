class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
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
      # 登録したらログインさせる
      log_in @user
      flash[:success] = 'Welcome to the Sample App'
      # redirect_to user_url(@user) # 下と同じ。railsが推察してやってくれる
      redirect_to @user
    else
      render 'new'
    end

  end



  private


  # Strong Parameters
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end




end
