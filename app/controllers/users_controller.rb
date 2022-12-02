class UsersController < ApplicationController
  def index
  end

  def show
    @user = User.find(params[:id])
    @prototypes = @user.prototypes
  end

end
