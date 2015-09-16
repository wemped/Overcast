class PlaylistsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	require 'rubygems'
	require 'json'

  # def create
  # 	playlist = Playlist.create(user_id: params[:user_id])
  # end

  def broadcast


  	# puts 'here'
  	# puts params
  	# for x in params
  	# 	key = x
  	# 	puts key
  	# 	puts 'drake'
  	# 	break
  	# end
  	# puts 'there'
  	# for y in key 
  	# 	break
  	# end
  	# puts 'other'
  	# data = ActiveSupport::JSON.decode(y)
  	# puts data

  	# puts data["title"]
  	# puts data.title

  	Playlist.find(user.id).update(broadcast_status: true)
  end

  def end_broadcast
  	Playlist.find(user.id).update(broadcast_status: false)
  end

  def all_broadcasts
  	Playlist.where(broadcast_status: true).select(:id, :user_id)
  end

  def all_playlists
  	Playlist.where(id: params[playlist_id])
  end

end
