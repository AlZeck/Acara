class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  #GET su /api/users/ 
  def index
    current_user = getUserBySK(params[:apiKey])
    if !current_user.nil? && params.has_key?(:apiKey)
      @user = User.all
      render json: @user.as_json(methods: %i[following followers])
    else
      render body: nil, status: 401
    end
  end
 
  #GET su /api/users/:id 
  def show
    current_user = getUserBySK(params[:apiKey])
    if !current_user.nil? && params.has_key?(:apiKey)
      @user = User.find(params[:id])
      events = Event.where(user_id: params[:id])
      
      render json: @user.as_json(methods: %i[following followers]).merge(events: events.as_json)
    else
      render body: nil, status: 401
    end
  end
end
