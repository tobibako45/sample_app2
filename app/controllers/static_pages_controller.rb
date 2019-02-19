class StaticPagesController < ApplicationController

  def home
    # ログインしている場合、current_userのmicropostオブジェクトを返す
    # @micropost = current_user.microposts.build if logged_in?

    # 1行のときは後置if文、2行以上のときは前置if文を使うのがRubyの慣習です。
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end

  end

  def help
  end

  def about
  end

  def contact
  end
end
