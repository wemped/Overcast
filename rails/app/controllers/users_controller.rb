class UsersController < ApplicationController
	skip_before_filter :verify_authenticity_token
	
	def create
  		user = User.find_by(username: params[:username])
  			if user and user.authenticate(params[:password])
  				user_info = User.where(id: user.id).select(:id, :username)
				render json: user_info
  			else 
				user = User.create(username: params[:username], password: params[:password], password_confirmation: params[:password_confirmation])
				user_info = User.where(id: user.id).select(:id, :username)
				render json: user_info
  			end
	end


  	

  	# def destroy
  	# 	session[:user_id] = nil
  	# 	redirect_to '/users'
  	# end
end
