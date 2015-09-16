class LikesController < ApplicationController

  def create
  	Like.create(playlist_id: params[:playlist_id], track_id: params[:track_id], user_id: params[:user_id])
  end

  def get_count
  	Like.where(playlist_id: params[:playlist_id], track_id: params[:track_id]).count
  end
  
end
