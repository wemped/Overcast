class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :user, index: true
      t.references :playlist, index: true
      t.references :track, index: true

      t.timestamps
    end
  end
end
