require "spec_helper"

describe Reddit::Internal::Processor do
  before(:each) do
    rspec_user = JSON.parse(File.read(File.expand_path("../../../../data/rspec_user.json", __FILE__)))

    @user = Reddit::Services::User.new  rspec_user["user"], rspec_user["password"], rspec_user["service_id"], rspec_user["secret"], "Ruby Reddit Api - Rspec Tests"
  end

  after(:each) do
    @user.connection.sign_out()
  end

  it "retrieve data from endpoint without basepath" do
    expect {Reddit::Internal::Processor.process("Listings", "get_hot", @user, nil, {basepath_subreddit:"worldnews"})}.not_to raise_error
  end

  it "retrieve data from endpoint with basepath" do
    expect {Reddit::Internal::Processor.process("Account", "get_me", @user, nil, {})}.not_to raise_error
  end

  it "raise exception when basepath_subreddit not given but required" do
    expect {Reddit::Internal::Processor.process("Listings", "get_hot", @user, nil, {})}.to raise_error(RuntimeError)
  end

  it "batch process on listing endpoints" do
    expect {Reddit::Internal::Processor.batch_call("Listings", "get_hot", @user, {page_size: 20, max_size:40, basepath_subreddit:"worldnews"})}.not_to raise_error
  end

  it "raise exception when page_size is missing" do
    expect {Reddit::Internal::Processor.batch_call("module", "function", nil, {max_size:0})}.to raise_error(RuntimeError)
  end

  it "raise exception when max_size is missing" do
    expect {Reddit::Internal::Processor.batch_call("module", "function", nil, {page_size:1})}.to raise_error(RuntimeError)
  end

  it "not allow page size to equal 0" do
    expect {Reddit::Internal::Processor.batch_call("module", "function", nil, {page_size:0, max_size:0})}.to raise_error(RuntimeError)
  end


end
