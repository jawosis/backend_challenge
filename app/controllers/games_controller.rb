class GamesController < ApplicationController
  before_filter :validate_running_game, :only => [:score, :reset_point]

  def validate_running_game
    @game = Game.find(params[:id])
    render_with_status(false, :unprocessable_entity, nil, "Game has already ended!")  if @game.ended
  end

  def show
    @game = Game.find(params[:id])
    render json: @game.as_info_hash
  end

  def create
    @game = Game.new(params[:game])
    if @game.save
      render json: {:game => @game.as_info_hash}, status: :created
    else
      render_with_status(false, :unprocessable_entity, @game, @game.errors)
    end
  end


  def destroy
    @game = Game.find(params[:id])
    @game.destroy
    render json: {:game => {:id => @game.id}}, status: :ok
  end

  def score
    @player = @game.players.where(:user_id => params[:player]).first
    unless @player
      render_with_status(false, :not_found, @game, "Player not found!")
    else
      @player.points += 1
      @player.save
      render json: {:game => @game.as_info_hash}, status: :ok
    end
  end

  def reset_point
    @player = @game.players.where(:user_id => params[:player]).first
    unless @player
      render_with_status(false, :not_found, @game, "Player not found!")
    else
      @player.points -= 1
      if @player.save
        render json: {:game => @game.as_info_hash}, status: :ok
      else
        render_with_status(false, :unprocessable_entity, @player, @player.errors)
      end
    end
  end

  def finish
    @game = Game.find(params[:id])
    @game.ended = true
    if @game.save
      render json: {:game => @game.as_info_hash}, status: :ok
    else
      render_with_status(false, :unprocessable_entity, @game, @game.errors)
    end
  end
end
