class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.references :playlist, index: true
      t.string :title
      t.string :artist
      t.string :album
      t.integer :duration
      t.string :playable_uri

      t.timestamps
    end
  end
end
