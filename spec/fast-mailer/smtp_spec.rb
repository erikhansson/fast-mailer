require File.expand_path('../../spec_helper', __FILE__)

describe FastMailer::SMTP do
  
  before(:all) do
    FastMailer::Configuration.enable_testing!
  end
  
  before(:each) do
    MockSMTP.clear_deliveries
  end
  
  
  
  describe 'initialization' do
    it "should pass it's options through FastMailer::Configuration" do
      smtp = FastMailer::SMTP.new 't22'
      smtp.configuration.should == FastMailer::Configuration::TEST_CONFIGURATION
    end
  end
  
  describe :open do
    it "should get a Net::SMTP instance and open it's connection for the block" do
      mail = Mail.new do
        to 'one@test.com'
        from 'two@test.com'
        subject 'testing'
        body 'testing smtp'
      end
      
      Net::SMTP.should_receive(:new).with(any_args).once.and_return(MockSMTP.new)
      smtp = FastMailer::SMTP.new
      smtp.open do
        smtp.deliver mail
        smtp.deliver mail
        smtp.deliver mail
      end
      MockSMTP.deliveries.should have(3).emails
    end
  end
  
end
