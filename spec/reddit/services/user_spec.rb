require "spec_helper"

describe Reddit::Services::User do
  before(:each) do
    rspec_user = JSON.parse(File.read(File.expand_path("../../../../data/rspec_user.json", __FILE__)))

    @user = Reddit::Services::User.new  rspec_user["user"], rspec_user["password"], rspec_user["service_id"], rspec_user["secret"], "Ruby Reddit Api - Rspec Tests"
  end

  after(:each) do
    @user.connection.sign_out()
  end

  it "should sign in a token" do
    expect(@user.token).not_to eq(nil)
  end

end
