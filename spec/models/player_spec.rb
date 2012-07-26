require 'spec_helper'

describe Player do
  before do
    @jochen = User.find_or_create_by_name("Jochen")
    @ale = User.find_or_create_by_name("Ale")
    @game = FactoryGirl.create(:game, :playerA => @jochen.id, :playerB => @ale.id)
    @playerA = @game.players.first
    @playerB = @game.players.last
  end

  it "instantiates with points = 0" do
    @playerA.points.should eq(0)
  end

  it "invalidates points less than 0" do
    @playerA.points = -1
    expect {@playerA.save!}.to raise_error("Validation failed: Points must be greater than or equal to 0")
  end

  it "freezes player updates if game ended" do
    @playerA.game.ended = true
    expect {@playerA.save!}.to raise_error("Validation failed: Game has already ended!")
  end

end
