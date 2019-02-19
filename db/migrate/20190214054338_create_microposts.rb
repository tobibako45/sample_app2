class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true

      t.timestamps
    end

    # インデックスの付与
    # user_idとcreated_atの両方を１つの配列に含めている点にも注目です。
    # こうすることでActive Recordは、両方のキーを同時に扱う複合キーインデックス (Multiple Key Index) を作成
    add_index :microposts, [:user_id, :created_at]

  end
end
