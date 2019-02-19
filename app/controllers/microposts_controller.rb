class MicropostsController < ApplicationController

  # ログイン済みユーザーかどうか確認
  before_action :logged_in_user, only: [:create, :destroy]
  # 正しいユーザーかどうか確認
  before_action :correct_user, only: :destroy


  def create
    @micropost = current_user.microposts.build(micropost_params)
    # マイクロソフト保存されたら
    if @micropost.save
      flash[:success] = "Micropost created! マイクロポストが作成されました"
      redirect_to root_url
    else
      # 空の@feed_itemsインスタンス変数を追加。空投稿対策
      @feed_items = []
      # viewのstatic_pages/homeを呼び出す
      render 'static_pages/home'
    end
  end


  def destroy
    # current_userのマイクロポストを削除
    @micropost.destroy
    flash[:success] = "Micropost deleted"

    # request.referrer 一つ前のURLを返す。デフォルトはroot_url(元に戻すURLが見つからなかった場合とかに)。
    # redirect_to request.referrer || root_url

    # これも上と同じ。Rails 5から新たに導入
    redirect_back(fallback_location: root_url)
  end




  private


  # Strong Parameters
  def micropost_params
    # requireでPOSTで受け取る値のキーを設定
    # permitで許可するカラムを設定
    params.require(:micropost).permit(:content, :picture)
  end

  # 正しいユーザー
  def correct_user
    # current_userにマイクロポストをidで検索して代入
    @micropost = current_user.microposts.find_by(id: params[:id])
    # マイクロポストがnilならroot_urlにリダイレクト
    redirect_to root_url if @micropost.nil?
  end


end
