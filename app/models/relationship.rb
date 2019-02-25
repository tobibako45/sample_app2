class Relationship < ApplicationRecord
  # relationshipモデルとフォローされているuserモデル(またはフォローしているuserモデル)は１対１となるため、
  # belongs_toで関連付けを行う。
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # バリデーション

  # Rails 5から必須ではなくなった。
  # validates :follower_id, presence: true
  # validates :followed_id, presence: true


end
