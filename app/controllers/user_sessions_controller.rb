class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def create
    @user_session = UserSession.new(params[:user])
    if @user_session.save
      flash[:success] = "Login successful!"
      redirect_to root_url
    else
      if !performed?
        redirect_to root_url
      end
      flash[:failure] = "Login failed. Were your credentials correct?"
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:success] = "Logout successful!"
    redirect_to root_url
  end

end