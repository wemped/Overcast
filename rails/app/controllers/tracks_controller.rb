class TracksController < ApplicationController

  def create

  	puts 'here'

  	puts params

  	data = JSON.parse(params[:track])

  	puts 'other' 

  	puts data 

  	puts data["title"]
  	
  	puts 'after'

  	Track.create(playlist_id: params[:playlist_id], title: params[:title], artist: params[:artist], album: params[:album], duration: params[:duration], playable_URI: params[:playable_URI], spotify_id: params[:spotify_id])
  end

  def destroy
  	Track.where(id: params[track_id], playlist_id: params[:playlist_id]).destroy_all
  end

end
