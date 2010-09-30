
module FastMailer
  
  # Sends messages using an SMTP server. The SMTP options is passed through
  # FastMailer::Configuration, so you can set your system up to automatically
  # use your SMTP configuration. Also, FastMailer::SMTP supports that you send
  # multiple emails over a single connection, allowing for faster delivery
  # of multiple emails.
  #
  # Note that if an error is raised by Net::SMTP, the connection may not be
  # reliable. As a best practice, always discard the current connection and
  # reopen a new one in case you encounter an error. Do not attempt to continue
  # sending mail on the same connection.
  class SMTP
    
    include Hooks

    define_hook :before_deliver
    define_hook :after_deliver

    attr_accessor :configuration
    
    def initialize(options = nil)
      @configuration = FastMailer::Configuration.smtp_configuration options
    end
    
    def open
      @opened = true

      configuration[:host] ||= configuration[:address]
      configuration[:username] ||= configuration[:user_name]
      
      @smtp = connection_class.new(configuration[:host], configuration[:port])
      if configuration[:enable_starttls_auto]
        smtp.enable_starttls_auto if smtp.respond_to?(:enable_starttls_auto) 
      end
      
      @smtp.start(configuration[:domain], configuration[:username], configuration[:password], configuration[:authentication]) do |smtp|
        yield self
      end
    ensure
      @smtp = nil
      @opened = false
    end
    
    def deliver(mail)
      if @opened
        perform_delivery(mail)
      else
        open do
          deliver mail
        end
      end
    end
    
    private
    def connection_class
      FastMailer.test_mode ? FastMailer::MockSMTP : Net::SMTP
    end
    
    def skip_delivery!
      @skip_delivery = true
    end
    
    def perform_delivery(mail)
      run_hook :before_deliver, mail
      
      if !@skip_delivery
        # Set the envelope from to be either the return-path, the sender or the first from address
        envelope_from = mail.return_path || mail.sender || mail.from_addrs.first
        if envelope_from.blank?
          raise ArgumentError.new('A sender (Return-Path, Sender or From) required to send a message') 
        end
      
        destinations ||= mail.destinations if mail.respond_to?(:destinations) && mail.destinations
        if destinations.blank?
          raise ArgumentError.new('At least one recipient (To, Cc or Bcc) is required to send a message') 
        end
      
        message ||= mail.encoded if mail.respond_to?(:encoded)
        if message.blank?
          raise ArgumentError.new('A encoded content is required to send a message')
        end
      
        begin
          @smtp.sendmail(message, envelope_from, destinations)
          run_hook :after_deliver, mail
        rescue Exception => e
          @smtp = nil
          run_hook :after_deliver, mail, e
          raise e
        end
      end
    ensure
      @skip_delivery = false
    end
    
  end
end
