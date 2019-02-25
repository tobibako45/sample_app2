class User < ApplicationRecord
  # ユーザーがマイクロポストを複数所有する (has_many) 関連付け
  # dependent: :destroyというオプションを使うと、ユーザーが削除されたときに、
  # そのユーザーに紐付いた (そのユーザーが投稿した) マイクロポストも一緒に削除される
  has_many :microposts, dependent: :destroy


  # 能動的関係に対して1対多 (has_many) の関連付けを実装する
  # active_relationships 能動的関係であることを示す為に名前付け。
  # class_name: "Relationship" 明示的にクラス名の名称を指定。
  # foreign_key: "follower_id" 明示的に外部キーの名称を指定。
  # dependent: :destroy ユーザーを削除したら、ユーザーのrelationshipも削除される設定
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy

  # 受動的関係を使ってuser.followersを実装する。
  # passive_relationships 名前付け
  # class_name: "Relationship" 明示的にクラス名の名称を指定。
  # foreign_key: "followed_id" 明示的に外部キーの名称を指定。
  # dependent: :destroy ユーザーを削除したら、ユーザーのrelationshipも削除される設定
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  # has_many throughのデフォルトの上書き
  # sourceで、「following配列の元はfollowed idの集合である」ということを明示的に
  has_many :following, through: :active_relationships, source: :followed

  # has_many throughのデフォルトの上書き
  # sourceで、「followers配列の元はfollower idの集合である」ということを明示的に
  has_many :followers, through: :passive_relationships, source: :follower
  # source: :followerを省略することも可能。 has_many :followersと記述した場合、
  # Railsは自動的にfollowersを単数形のfollowerに変換して、follower_idを探してくれる。
  # 今回は、has_many :followingとの類似性を強調するために、 あえて記述している。


  # remember_token 永続セッションに使う
  # activation_token 有効化に使う
  # reset_token パスワード再設定に使う
  attr_accessor :remember_token, :activation_token, :reset_token

  # before_save オブジェクトがDBに保存される直前で実行。INSERT、UPDATE両方で実行
  # このselfは、現在のユーザーを指す
  # before_save { self.email = email.downcase} # .downcase 少文字に変換。
  # before_save {email.downcase!} # .downcase!で直接変更できる。

  # 上をメソッドに変更
  before_save :downcase_email

  # オブジェクトがDBに新規保存(INSERT)される直前に実行。
  # 有効化トークンとダイジェストを作成および代入する
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: 50}

  # メールフォーマットを正規表現で検証
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, presence: true, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX}, # メールのフォーマット
            # uniqueness: true # メールアドレスの一意性を検証
            uniqueness: {case_sensitive: false} # メールアドレスの大文字小文字を無視した一意性の検証

  # パスワードのハッシュ化。bcrypt gemを追加したことで使える
  has_secure_password
  # validates :password, presence: true, length: {minimum: 6}

  # 空の時に例外処理を加える
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  # :case_sensitiveオプションを用いて、
  # 大文字小文字の違いを確認する制約をかけるかどうかを定義することもできます。
  # デフォルトでは、このオプションはtrueになります。
  #
  # allow_nil: trueで、
  # 新規ユーザー登録時に空のパスワードが有効になってしまうのかと心配になるかもしれませんが、安心してください。
  # has_secure_passwordでは (追加したバリデーションとは別に) オブジェクト生成時に存在性を検証するようになっているため、
  # 空のパスワード (nil) が新規ユーザー登録時に有効になることはありません。
  # (空のパスワードを入力すると存在性のバリデーションとhas_secure_passwordによるバリデーションがそれぞれ実行され、
  # 2つの同じエラーメッセージが表示されるというバグがありましたが、これで解決できました。)


  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    # base64 トークンジェネレーター
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    # accessorでremember_tokenと変数定義して、User.new_token（base64で作られたトークン）を代入。
    # self.remember_token = 'こうやって保存しておく'
    self.remember_token = User.new_token

    # さらにUser.digestでハッシュした値を、update_attributeでDB内のremember_digest属性に保存。
    update_attribute(:remember_digest, User.digest(remember_token))

    # update_attributeは、バリデーションを素通りさせます。
    # 今回はユーザーのパスワードやパスワード確認にアクセスできないので、
    # バリデーションを素通りさせなければなりません。
  end


  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # def authenticated?(remember_token) # このremember_tokenは、accessorのではなく、引数のローカル変数
  #   # remember_digestがnilの場合はfalse 早期return
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  #   # 実際、remember_digestの属性はデータベースのカラムに対応しているため、
  #   # Active Recordによって簡単に取得したり保存したりできます
  # end


  # トークンがダイジェストと一致したらtrueを返す
  # sendメソッドで抽象化
  def authenticated?(attribute, token)
    # sendメソッドに渡すシンボルは、attributeとして引数に追加する。
    # sendメソッドは、self.sendでも呼べるが、Userモデル内であるため省略している。
    # もう1つの引数であるtokenは他の認証でも使えるように、名称を一般化している。
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    # DBのremember_digest属性をnilに更新する
    update_attribute(:remember_digest, nil)
  end


  # アカウントを有効化する
  def activate
    # 有効化ステータスをtrueに更新する
    # update_attribute(:activated, true)
    # # 有効化時刻を現在時刻で更新する
    # update_attribute(:activated_at, Time.zone.now)

    # まとめる
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # アカウント有効化メールを送信。deliver_nowは、メールを送信するメソッド。
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    # self.reset_tokenはattr_accessorで追加したやつ。DBにないから
    self.reset_token = User.new_token
    # DBのreset_digestとreset_sent_atを更新

    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end


  # パスワード再設定のメールを送信する
  def send_password_reset_email
    # deliver_nowは、メールを送信するメソッド。
    UserMailer.password_reset(self).deliver_now
  end


  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    # 現在時刻より２時間以上前(早い)場合
    reset_sent_at < 2.hours.ago
  end


  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」でやる
  # def feed
  #   Micropost.where("user_id = ?", id)
  # end


  # ユーザーのステータスフィードを返す（サブセレクト前）
  # def feed
    # following_idsメソッドは、has_many :followingの関連付けしたときに、ActiveRecordが自動生成したもの。
    # これにより、user.following(userがフォローしているユーザー)のidが配列として扱える。
    # 関連付けしている名前の末尾に _ids を付け足すだけで使える。
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)

    # 自分自身のマイクロポストを含めない場合
    # Micropost.where("user_id IN (?)", following_ids)

    # 自分自身のマイクロポストだけ
    # Micropost.where("user_id = ?", id)

    # フォローしていないユーザーのも含めたマイクロポスト(すなわち、全て)
    # Micropost.all

    # リファクタリング。変数にキーと値のペアを使う
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #                 following_ids: following_ids, user_id: id)
  # end

  # ユーザーのステータスフィードを返す（サブセレクト版）
  def feed
    # サブセレクトを文字列として代入
    # following_idsという文字列はエスケープされているのではなく、見やすさのために式展開しているだけだという点に注意
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)

    # SELECT * FROM microposts
    # WHERE user_id IN (SELECT followed_id FROM relationships WHERE  follower_id = 1)
    # OR user_id = 1
  end



  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end



  private

  # メールアドレスを全て小文字にする
  def downcase_email
    # self.email = email.downcase
    email.downcase!
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    # self.activation_tokenはattr_accessorで追加したやつ
    self.activation_token = User.new_token
    # self.activation_digestはActiveRecordのやつ
    self.activation_digest = User.digest(activation_token)
  end


end
