class UsersController < ApplicationController

    skip_before_filter :verify_authenticity_token, :only => [:create]

    def create
        @user = User.where(:email => user_params[:email]).first_or_create
        @user.update(user_params)
        if @user.save
            respond_to do |format|
                format.json  { render :json => @user.json_presentation }
            end
        else
            respond_to do |format|
                msg = { :error_code => 1000, :message => 'failed in creating new user' }
                format.json  { render :json => msg }
            end
        end
    end

    private
    def user_params
        params.require(:user).permit(:email, :access_token, :refresh_token)
    end
end
