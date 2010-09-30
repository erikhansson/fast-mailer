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
  
  describe ":deliver callbacks" do
    before(:each) do
      @mail = Mail.new do
        to 'one@test.com'
        from 'two@test.com'
        subject 'testing'
        body 'testing smtp'
      end
    end
    
    after(:each) do
      FastMailer.class_variable_set '@@before_deliver', nil
    end
    
    
    it "should call FastMailer.before_deliver before delivering a mail" do
      executed = false
      FastMailer.before_deliver do
        executed = true
      end
      executed.should be_false
      FastMailer::SMTP.new.deliver @mail
      executed.should be_true
    end
    
    it "should call FastMailer.after_deliver before delivering a mail" do
      executed = false
      FastMailer.after_deliver do
        executed = true
      end
      executed.should be_false
      FastMailer::SMTP.new.deliver @mail
      executed.should be_true
    end
    
    it "should cancel if FastMailer.before_deliver returns false" do
      FastMailer.before_deliver() { false }
      FastMailer::SMTP.new.deliver @mail
      FastMailer::MockSMTP.deliveries.size.should == 0
    end
    
    it "should pass any exception to FastMailer.after_deliver" do
      mock = FastMailer::MockSMTP.new
      mock.should_receive(:sendmail).once.and_raise(ArgumentError.new "foobar")
      FastMailer::MockSMTP.should_receive(:new).once.and_return mock
      
      executed = false
      FastMailer.after_deliver do |mail, exception|
        mail.to[0].should == 'one@test.com'
        exception.message.should == 'foobar'
        executed = true
      end
      
      executed.should be_false
      -> do
        FastMailer::SMTP.new.deliver @mail
      end.should raise_exception
      executed.should be_true
    end
  end
  
end
