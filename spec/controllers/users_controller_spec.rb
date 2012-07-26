require 'spec_helper'

describe UsersController do
  before do
    @valid_user_params = FactoryGirl.attributes_for(:user)
    @invalid_user_params = FactoryGirl.attributes_for(:user, :name => nil)
  end

  it "creates user and returns valid json response and code" do
    new_user = {:id => 1, :loses_count => 0, :name => "Jochen", :wins_count => 0}
    expect {post :create, :user => @valid_user_params}.to change(User, :count).by(1)
    response.body.should be_json_eql(new_user.to_json)
    response.response_code.should == 201
  end

  it "updates user and returns valid json response and code" do
    updated_user = {:id => 1, :loses_count => 0, :name => "Jockel", :wins_count => 0}
    post :create, :user => @valid_user_params
    put :update, :id => 1, :user => { :name => "Jockel"}
    response.body.should be_json_eql(updated_user.to_json)
    response.response_code.should == 200
  end


  it "destroys user and returns valid json" do
    deleted_user = {:id => 1, :loses_count => 0, :name => "Jochen", :wins_count => 0}
    post :create, :user => @valid_user_params
    expect {delete :destroy, :id => 1}.to change(User, :count).by(-1)
    response.body.should be_json_eql(deleted_user.to_json)
    response.response_code.should == 200
  end

  it "shows user" do
    existing_user = {:id => 1, :loses_count => 0, :name => "Jochen", :wins_count => 0}
    post :create, :user => @valid_user_params
    get :show, :id => 1
    response.body.should be_json_eql(existing_user.to_json)
  end

  it "validates presence of name" do
    errors = {:errors => {:name => ["can't be blank"]}}
    post :create, :user => @invalid_user_params
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 422
  end

  it "returns not found code if non existing user_id specified" do
    errors = {:errors => "Record not found!"}
    post :create, :user => @valid_user_params
    get :show, :id => 99
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 404
    put :update, :id => 99
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 404
    delete :destroy, :id => 99
    response.body.should be_json_eql(errors.to_json)
    response.response_code.should == 404
  end

  it "returns the leader bord" do
    players = {:players => [{:id => 2, :name => "Ale", :loses_count => 9, :wins_count => 21}, {:id => 1, :name => "Jochen", :loses_count => 10, :wins_count => 20}]}
    post :create, :user => FactoryGirl.attributes_for(:user, :wins_count => 20, :loses_count => 10)
    post :create, :user => FactoryGirl.attributes_for(:user, :name => "Ale", :wins_count => 21, :loses_count => 9)
    get :leaderboard
    response.body.should be_json_eql(players.to_json)
    response.response_code.should == 200
  end

end
