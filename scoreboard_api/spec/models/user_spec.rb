require 'spec_helper'

describe User do

  before do
    @user = FactoryGirl.build(:user)
  end

  it "instantiates with loses_count = 0" do
    @user.loses_count == 0
  end

  it "instantiates with wins_count = 0" do
    @user.wins_count == 0
  end

  it "is invalid without a name" do
    @user.name = nil
    @user.should_not be_valid
  end

end
