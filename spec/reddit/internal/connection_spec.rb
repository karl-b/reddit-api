require "spec_helper"

describe Reddit::Internal::Connection do
  before(:each) do
    rspec_user = JSON.parse(File.read(File.expand_path("../../../../data/rspec_user.json", __FILE__)))

    @connection = Reddit::Internal::Connection.new  rspec_user["user"], rspec_user["password"], rspec_user["service_id"], rspec_user["secret"], "Ruby Reddit Api - Rspec Tests"
    @connection.sign_in()
  end

  after(:each) do
    @connection.sign_out()
  end

  it "should sign in a token" do
    expect(@connection.token).not_to eq(nil)
  end
  it "should sign out a token" do
    @connection.sign_out()
    expect(@connection.token).to eq(nil)
  end
  it "should thottle requests by default" do
    expect(@connection.request_throttle).to eq(true)
  end
end
