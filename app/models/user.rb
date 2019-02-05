class User < ApplicationRecord

  attr_accessor :remember_token

  # before_save オブジェクトがDBに保存される直前で実行。INSERT、UPDATE両方で実行
  # このselfは、現在のユーザーを指す
  # before_save { self.email = email.downcase} # .downcase 少文字に変換。
  before_save {email.downcase!} # .downcase!で直接変更できる。

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
  def authenticated?(remember_token) # このremember_tokenは、accessorのではなく、引数のローカル変数

    # remember_digestがnilの場合はfalse 早期return
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
    # 実際、remember_digestの属性はデータベースのカラムに対応しているため、
    # Active Recordによって簡単に取得したり保存したりできます
  end


  # ユーザーのログイン情報を破棄する
  def forget
    # DBのremember_digest属性をnilに更新する
    update_attribute(:remember_digest, nil)
  end


end
