require 'spec_helper'


describe GamesController do
  before do
    @playerA = FactoryGirl.create(:user)
    @playerB = FactoryGirl.create(:user, :name => "Ale")
    @game_attributes = FactoryGirl.attributes_for(:game, :playerA => @playerA.id, :playerB => @playerB.id)
  end

  it "creates game and returns valid json response and code" do
    new_game = {:game => {:id => 1, :players => [{:id => 1, :points => 0}, {:id => 2, :points => 0}], :winner => 0}}
    expect {post :create, :game => @game_attributes}.to change(Game, :count).by(1)
    response.body.should be_json_eql(new_game.to_json)
    response.response_code.should == 201
  end


  it "throws adecuate validation errors and response code with invalid game" do
    duplicate_user_error = {:errors => {:playerB => ["cannot be the same as playerA!"]}}
    nonexisting_user_error = {:errors => {:playerB => ["is not an existing user!"]}}
    post :create, :game => FactoryGirl.attributes_for(:game, :playerA => @playerA.id, :playerB => @playerA.id)
    response.body.should be_json_eql(duplicate_user_error.to_json)
    response.response_code.should == 422
    post :create, :game => FactoryGirl.attributes_for(:game, :playerA => @playerA.id, :playerB => 99)
    response.body.should be_json_eql(nonexisting_user_error.to_json)
    response.response_code.should == 422
  end

  it "returns not found error if game does not exist" do
    errors = {:errors => "Record not found!"}
    get :show, :id => 1
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 404
    post :create, :game => @game_attributes
    post :score, :id => 2, :player => @playerA.id
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 404
    post :score, :id => 1, :player => @playerA.id
    delete :reset_point, :id => 2, :player => @playerA.id
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 404
    put :finish, :id => 2
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 404
  end

  it "returns not found error if player does not exist" do
    errors = {:errors => "Player not found!"}
    post :create, :game => @game_attributes
    post :score, :id => 1, :player => 99
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 404
  end


  it "scores a point" do
    game_info = {:game => {:id => 1, :players => [{:id => 1, :points => 1}, {:id => 2, :points => 0}], :winner => 0}}
    post :create, :game => @game_attributes
    game = Game.first
    game.players.where(:user_id => @playerA.id).first.points.should == 0
    post :score, :id => 1, :player => @playerA.id
    game.players.where(:user_id => @playerA.id).first.points.should == 1
    response.body.should be_json_eql(game_info.to_json)
    response.response_code.should == 200
  end


  it "resets a point" do
    post :create, :game => @game_attributes
    post :score, :id => 1, :player => @playerA.id
    game = Game.first
    game.players.where(:user_id => @playerA.id).first.points.should == 1
    delete :reset_point, :id => 1, :player => @playerA.id
    game.players.where(:user_id => @playerA.id).first.points.should == 0
  end

  it "validates that player's points are greater or equal to 0" do
    validation_error = {:errors => {:points => ["must be greater than or equal to 0"]}}
    post :create, :game => @game_attributes
    delete :reset_point, :id => 1, :player => @playerA.id
    response.body.should be_json_eql(validation_error.to_json)
    response.response_code.should == 422
  end

  it "ends a game returning the winner" do
    validation_error = {:errors => "Game has already ended!"}
    game_info = {:game => {:id => 1, :players => [{:id => 1, :points => 10}, {:id => 2, :points => 9}], :winner => 1}}
    post :create, :game => @game_attributes
    Game.first.players.each do |p|
      p.points = 9
      p.save
    end
    post :score, :id => 1, :player => @playerA.id
    put :finish, :id => 1
    response.body.should be_json_eql(game_info.to_json)
    response.response_code.should == 200
    Game.first.ended.should be_true
    post :score, :id => 1, :player => @playerA.id
    response.body.should be_json_eql(validation_error.to_json)
    response.response_code.should == 422
  end

  it "should return no winner if players equal points" do
    validation_error = {:errors => "Game has already ended!"}
    game_info = {:game => {:id => 1, :players => [{:id => 1, :points => 9}, {:id => 2, :points => 9}], :winner => 0}}
    post :create, :game => @game_attributes
    Game.first.players.each do |p|
      p.points = 9
      p.save
    end
    put :finish, :id => 1
    response.body.should be_json_eql(game_info.to_json)
    response.response_code.should == 200
    Game.first.ended.should be_true
    post :score, :id => 1, :player => @playerA.id
    response.body.should be_json_eql(validation_error.to_json)
    response.response_code.should == 422
  end

  it "should destroy all players when game ist destroyed" do
    game_info = {:game => {:id => 1}}
    post :create, :game => @game_attributes
    Player.all.size.should == 2
    delete :destroy, :id => 1
    response.body.should be_json_eql(game_info.to_json)
    response.response_code.should == 200
    Player.all.size.should == 0
  end

end
