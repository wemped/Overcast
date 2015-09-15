class RemoveSocketIdFromPlaylist < ActiveRecord::Migration
  def change
    remove_column :playlists, :socket_id, :string
  end
end
