class AdminController < ApplicationController
  before_action :require_user_be_admin!

  def show
  end
end
