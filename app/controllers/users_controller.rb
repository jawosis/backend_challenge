class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    render_with_status(true, :ok, @user)
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      render_with_status(true, :created, @user)
    else
      render_with_status(false, :unprocessable_entity, @user, @user.errors)
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      render_with_status(true, :ok, @user)
    else
      render_with_status(false, :unprocessable_entity, @user, @user.errors)
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render_with_status(true, :ok, @user)
  end

  def leaderboard
    @players = User.all.sort! {|a,b| (b.wins_count - b.loses_count) <=> (a.wins_count - a.loses_count)}
    render json: {:players => @players.as_json}, status: :ok
  end
end
