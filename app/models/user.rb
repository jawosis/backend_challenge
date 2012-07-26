class User < ActiveRecord::Base
  has_many :games
  has_many :players
  attr_accessible :loses_count, :name, :wins_count

  validates :name, :presence => true


  def as_json(options={})
    super(:only => [:id, :loses_count, :name, :wins_count])
  end
end
