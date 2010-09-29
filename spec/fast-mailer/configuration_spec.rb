require File.expand_path('../../spec_helper', __FILE__)

describe FastMailer::Configuration do

  describe :smtp_configuration do
    it "should return a hash as-is" do
      result = FastMailer::Configuration.smtp_configuration :foo => :bar
      result.should == { :foo => :bar }
    end
    
    it "should load settings from the named file if argument is not a Hash, and not nil" do
      filename = 'sample-file-name'
      File.should_receive(:read).with(filename).and_return "{ :foo => :bar }"
      result = FastMailer::Configuration.smtp_configuration filename
      result.should == { :foo => :bar }
    end
    
    it "should load the default settings if no argument is given or if argument is nil" do
      File.should_receive(:read).twice.with(File.expand_path("~/.config/smtp.rb")).and_return "{ :foo => :bar }"
      result = FastMailer::Configuration.smtp_configuration
      result.should == { :foo => :bar }
      result = FastMailer::Configuration.smtp_configuration nil
      result.should == { :foo => :bar }
    end
    
    it "should return test settings irrespective of argument if test-mode is enabled" do
      FastMailer::Configuration.enable_testing!
      FastMailer::Configuration.smtp_configuration.should == FastMailer::Configuration::TEST_CONFIGURATION
      FastMailer::Configuration.smtp_configuration(nil).should == FastMailer::Configuration::TEST_CONFIGURATION
      FastMailer::Configuration.smtp_configuration({ :foo => :bar }).should == FastMailer::Configuration::TEST_CONFIGURATION
      FastMailer::Configuration.smtp_configuration('config.rb').should == FastMailer::Configuration::TEST_CONFIGURATION
    end
  end
  
end
