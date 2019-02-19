class Micropost < ApplicationRecord
  # マイクロポストがユーザーに所属する (belongs_to) 関連付
  belongs_to :user

  # default_scope DBから要素を取得したときのデフォルトを指定するメソッド
  # マイクロポストを順序付ける
  default_scope -> { order(created_at: :desc) }

  # 画像を追加。引数に、属性名のシンボルと生成したアップローダーのクラス名
  mount_uploader :picture, PictureUploader

  # user_idに対するバリデーション
  validates :user_id, presence: true
  # contentに対するバリデーション
  validates :content, presence: true, length: {maximum: 140}
  # アップロードされた画像のサイズをバリデーション
  validate :picture_size


  private

  # アップロードされた画像のサイズをバリデーションする
  def picture_size
    # ５MBを超えた場合
    if picture.size > 5.megabytes
      # errorsコレクションに、カスタマイズしたエラーメッセージを追加
      errors.add(:picture, "should be less than 5MB 5MB以下にしてください")
    end
  end

end
