class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  attr_accessible :points, :user, :game


  validates :game, :presence => true
  validates :user, :presence => true
  validates :user_id, :uniqueness => {:scope => :game_id}
  validates :points, :numericality => {:greater_than_or_equal_to => 0}

  validate :running_game


  def running_game
    errors.add(:game, "has already ended!") if self.game.ended
  end


end
