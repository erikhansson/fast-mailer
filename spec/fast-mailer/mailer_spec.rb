require File.expand_path('../../spec_helper', __FILE__)

describe FastMailer::Mailer do
  
  before(:each) do
    FastMailer::MockSMTP.clear_deliveries
    @mail = Mail.new do
      to 'one@test.com'
      from 'two@test.com'
      subject "subject"
      body 'testing mailer'
    end
  end
  

  describe :send_all do
    it "should send every mail returned by the generator" do
      g = Enumerator.new do |g|
        10.times do |n|
          g.yield @mail
        end
      end
      
      mailer = FastMailer::Mailer.new
      mailer.send_all g
      
      FastMailer::MockSMTP.deliveries.size.should == 10
    end
    
    it "should not reopen the connection if there are no errors" do
      smtp = FastMailer::SMTP.new
      smtp.should_receive(:open).once.and_yield
      smtp.should_receive(:deliver).twice
      
      FastMailer::SMTP.should_receive(:new).with(any_args).once.and_return smtp
      FastMailer::Mailer.new.send_all [@mail, @mail].enum_for
    end
    
    it "should reopen the connection in case there's an error" do
      smtp = FastMailer::SMTP.new
      smtp.should_receive(:open).twice.and_yield
      smtp.should_receive(:deliver).twice.and_raise ArgumentError.new('Bad error')
      
      FastMailer::SMTP.should_receive(:new).with(any_args).once.and_return smtp
      
      FastMailer::Mailer.new.send_all [@mail, @mail].enum_for
    end
  end
  
end
