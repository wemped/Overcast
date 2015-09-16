class ListenersController < ApplicationController

  def create
  	Listener.create(playlist_id: params[:playlist_id], user_id: params[:user_id])
  end

  def destroy
  	Listener.where(user_id: params[:user_id]).destroy_all
  end

end
