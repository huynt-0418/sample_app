class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def show
    @pagy, @microposts = pagy @user.microposts.newest, items: Settings.default.page_10
  end

  def index
    @pagy, @users = pagy(
      User.all,
      items: Settings.default.page_10
    )
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "views.sign_up.check_email"
      redirect_to root_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "views.users.update.success_message"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "views.users.destroy.success_message"
    else
      flash[:danger] = t "views.users.destroy.fail_message"
    end
    redirect_to users_path
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "views.users.not_found"
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(User::USER_PARAMS)
  end

  def correct_user
    return if current_user?(@user)

    flash[:danger] = t "views.users.can_not_edit"
    redirect_to root_url
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
