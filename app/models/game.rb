class Game < ActiveRecord::Base
  has_many :players, :dependent => :destroy
  has_many :users, :through => :players

  attr_accessor :playerA, :playerB
  attr_accessible :ended, :playerA, :playerB

  validates :playerA, :playerB, :presence => :true, :on => :create
  validate :valid_players, :on => :create

  before_create :setup_players


  def valid_players
    errors.add(:playerA, "is not an existing user!") unless User.exists?(playerA)
    errors.add(:playerB, "is not an existing user!") unless User.exists?(playerB)
    errors.add(:playerB, "cannot be the same as playerA!") if playerA == playerB
  end

  def setup_players
    self.players.build(:user => User.find(playerA))
    self.players.build(:user => User.find(playerB))
  end

  def winner
    winner_id = 0
    if self.ended
      points = []
      self.players.map {|p| points << p.points unless points.include?(p.points)}
      winner_id = self.players.order("points DESC").first.user_id if points.length > 1
    end
    return winner_id
  end

  def as_json(options={})
    super(:only => [:id, :winner],
         :include => {
           :players => {:only => [:user_id, :points]}
         })
  end

  def as_info_hash
      {:id => self.id, :players => self.players.map {|p| {:id => p.user_id, :points => p.points}}, :winner => self.winner}
  end
end
