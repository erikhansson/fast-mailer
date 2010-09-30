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
    before(:all) do
      @smtp_class = Class.new(FastMailer::SMTP)
      @smtp_class.class_eval do
        attr_accessor :executed
        
        def mark_executed(*args)
          @executed = true
        end
      end
    end
    
    before(:each) do
      @mail = Mail.new do
        to 'one@test.com'
        from 'two@test.com'
        subject 'testing'
        body 'testing smtp'
      end
    end
    
    
    it "should call FastMailer.before_deliver before delivering a mail" do
      c = Class.new(@smtp_class)
      c.class_eval do
        before_deliver :mark_executed
      end
      
      smtp = c.new
      smtp.executed.should be_false
      smtp.deliver @mail
      smtp.executed.should be_true
    end
    
    it "should call FastMailer.after_deliver before delivering a mail" do
      c = Class.new(@smtp_class)
      c.class_eval do
        after_deliver :mark_executed
      end
      
      smtp = c.new
      smtp.executed.should be_false
      smtp.deliver @mail
      smtp.executed.should be_true
    end
    
    it "should cancel if a before_deliver hook calls :skip_delivery!" do
      c = Class.new(@smtp_class)
      c.class_eval do
        before_deliver :skip_delivery
        def skip_delivery(mail)
          skip_delivery!
        end
      end
      
      smtp = c.new
      smtp.deliver @mail
      FastMailer::MockSMTP.deliveries.size.should == 0
    end
    
    it "should pass any exception to FastMailer.after_deliver" do
      mock = FastMailer::MockSMTP.new
      mock.should_receive(:sendmail).once.and_raise(ArgumentError.new "foobar")
      FastMailer::MockSMTP.should_receive(:new).once.and_return mock
      
      c = Class.new(@smtp_class)
      c.class_eval do
        attr_accessor :exception
        after_deliver :callback
        def callback(mail, exception = nil)
          @exception = exception
        end
      end
      
      smtp = c.new
      smtp.exception.should be_nil
      -> do
        smtp.deliver @mail
      end.should raise_exception
      smtp.exception.should be_a_kind_of(ArgumentError)
    end
  end
  
end
