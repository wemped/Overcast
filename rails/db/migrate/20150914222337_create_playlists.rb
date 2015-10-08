class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.references :user, index: true
      t.string :socket_id

      t.timestamps
    end
  end
end
