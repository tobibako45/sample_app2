class User < ApplicationRecord

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
  validates :password, presence: true, length: {minimum: 6}

  # :case_sensitiveオプションを用いて、
  # 大文字小文字の違いを確認する制約をかけるかどうかを定義することもできます。
  # デフォルトでは、このオプションはtrueになります。





  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

end
