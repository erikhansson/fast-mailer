# encoding: utf-8

require File.expand_path('../../spec_helper', __FILE__)

describe "FastMailer::FileBlacklist" do
  
  BLACKLIST_PATH = File.expand_path('../../fixtures/blacklist.txt', __FILE__)
  
  before(:each) do
    @blacklist = FastMailer::FileBlacklist.new BLACKLIST_PATH
  end
  
  describe "when initialized with a blacklist file" do
    describe :blacklisted? do
      it "should return true for emails found in the blacklist" do
        @blacklist.blacklisted?('foo@blacklist.com').should be_true
      end
      it "should return false for emails not found in the blacklist" do
        @blacklist.blacklisted?('foo@whites.com').should be_false
      end
    end
    
    it "should load the blacklist as a UTF-8 text file" do
      @blacklist.blacklisted?('åäö@blacklist.com').should be_true
    end
  end
  
end
