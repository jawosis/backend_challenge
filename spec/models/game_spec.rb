require 'spec_helper'

describe Game do

  before do
    @jochen = User.find_or_create_by_name("Jochen")
    @ale = User.find_or_create_by_name("Ale")
    @game = FactoryGirl.build(:game, :playerA => @jochen.id, :playerB => @ale.id)
  end

  it "invalidates as only one player is specified" do
    @game.playerB = nil
    @game.should_not be_valid 
  end

  it "invalidates as one player refers to an unexisting user" do
    @game.playerB = 99
    @game.should_not be_valid 
  end

  it "invalidates as both players are the same user" do
    @game.playerB = @game.playerA
    @game.should_not be_valid
  end


  it "validates correctly" do
    @game.should be_valid
  end

  it "should exist 2 players for an existing game" do
    @game.save
    @game.players.size.should eq(2)
  end

  it "should instantiate as a game which is not ended yet" do
     @game.ended.should be_false
  end

  it "should return no winner if game not ended yet" do
    @game.winner.should == 0
  end


  it "should return a winner if game ended" do
    @game.save
    playerA = @game.players.first
    playerA.points = 10
    playerA.save
    @game.ended = true
    @game.winner.should eq(playerA.user.id)
  end

end
