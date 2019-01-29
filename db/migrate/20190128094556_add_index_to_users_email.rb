class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    # メールアドレスの一意性を強制するためのmigration
    # add_index :テーブル名, カラム名
    add_index :users, :email, unique: true
  end
end
