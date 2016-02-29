require "spec_helper"

describe Reddit::Services do
  it "should load and parse reddit_api.json" do
    expect{JSON.parse(File.read(File.expand_path("../../../data/reddit_api.json", __FILE__)))}.not_to raise_error
  end

end
