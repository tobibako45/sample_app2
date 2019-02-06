class AccountActivationsController < ApplicationController


  def edit

    # 有効化メールのリンクから、GETでemailを受け取って、検索
    user = User.find_by(email: params[:email])

    # ユーザーが存在する、かつ、有効化されていないユーザー、かつ、有効化トークンによる認証ができる
    if user && !user.activated? && user.authenticated?(:activation, params[:id])

      # # 有効化ステータスをtrueに更新する
      # user.update_attribute(:activated, true)
      # # 有効化時刻を現在時刻で更新する
      # user.update_attribute(:activated_at, Time.zone.now)

      # 上をモデルにメソッド化
      user.activate

      # 有効化時刻を現在時刻で更新する
      log_in user
      # フラッシュメッセージにsuccessをセットする
      flash[:success] = "Account activate! アカウントを有効にしました！"
      # ユーザー情報ページへリダイレクトする
      redirect_to user
    else
      # フラッシュメッセージにdangerをセットする
      flash[:danger] = "Invalid activation link アクティベーションリンクが無効です"
      # ルートURLにリダイレクトする
      redirect_to root_url
    end


  end

end
