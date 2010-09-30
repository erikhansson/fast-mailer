require File.expand_path('../../spec_helper', __FILE__)

describe FastMailer::SMTP do
  
  before(:each) do
    FastMailer::MockSMTP.clear_deliveries
  end
  
  
  
  describe 'initialization' do
    it "should pass it's options through FastMailer::Configuration" do
      FastMailer::Configuration.should_receive(:smtp_configuration).once.with(any_args).and_return 42
      smtp = FastMailer::SMTP.new 't22'
      smtp.configuration.should == 42
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
      
      smtp = FastMailer::SMTP.new
      smtp.should_receive(:connection_class).once.and_return FastMailer::MockSMTP
      smtp.open do
        smtp.deliver mail
        smtp.deliver mail
        smtp.deliver mail
      end
      FastMailer::MockSMTP.deliveries.should have(3).emails
    end
  end
  
end
