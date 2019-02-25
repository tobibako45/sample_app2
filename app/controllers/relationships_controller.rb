class RelationshipsController < ApplicationController

  # ログイン済みユーザーかどうか確認
  before_action :logged_in_user

  def create
    # ビューで変数を扱うために、userを@userに変更する。

    # followボタンからparams[:followed_id]で、Userモデルからユーザーを検索
    @user = User.find(params[:followed_id])
    # current_userが、userをフォローする
    current_user.follow(@user)

    # Ajax対応
    # format.出力形式で返すフォーマットを定義する。
    # 1つのアクションから複数のフォーマットで返す場合、複数行記述する。
    # ただし、実行されるのはそのうち1つになる。
    respond_to do |format|
      # つまり、フォーマットがhtmlなら、ユーザプロフィールへリダイレクトして、
      format.html {redirect_to @user}
      # フォーマットがjsなら、Ajax処理を行う。
      format.js
    end
    # redirect_to user
  end

  def destroy
    # ビューで変数を扱うために、userを@userに変更する。

    # unfollowボタンからparams[:followed_id]で、Relationshipモデルからフォローされているユーザーを検索
    @user = Relationship.find(params[:id]).followed
    # current_userが、userのフォローを解除する
    current_user.unfollow(@user)

    # Ajax対応
    respond_to do |format|
      format.html {redirect_to @user}
      format.js
    end
    # redirect_to user
  end


end
