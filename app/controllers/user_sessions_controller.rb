class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def create
    @user_session = UserSession.new(params[:user_session])
    
     if @user_session.save
      flash[:success] = "Login successful!" 
    else
      flash[:failure] = "Use a valid Email and Password"
    end
    redirect_back_or_default root_url
  end
  
  def destroy
    current_user_session.destroy
    flash[:success] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
end