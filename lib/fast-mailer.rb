
require 'mail'

require 'fast-mailer/configuration'
require 'fast-mailer/smtp'

module FastMailer
  class <<self
    def test_mode=(value)
      require 'fast-mailer/mock_smtp' if value
      @@test_mode = value
    end
  
    def test_mode
      @@test_mode ||= false
    end
    
    
    # Saves a code block to be executed before any email is sent by
    # FastMailer. Note that currently only one block will be saved,
    # so don't use this at a lot of different places.
    #
    # The callback will receive the mail to be sent as an only argument.
    # If it returns false or nil, the mail will not be sent.
    def before_deliver(&block)
      @@before_deliver = block
    end
    
    def on_before_deliver(mail)
      if before = (@@before_deliver ||= nil)
        before.call mail
      else
        true
      end
    end
    
    # Registers a code block to be executed after an email is sent by
    # FastMailer. Note that only one block will be saved, so don't use
    # this for more than one block.
    #
    # The callback will receive the mail that was sent, and any exceptions
    # raised by :sendmail.
    def after_deliver(&block)
      @@after_deliver = block
    end
    
    def on_after_deliver(mail, exception = nil)
      if after = (@@after_deliver ||= nil)
        after.call mail, exception
      end
    end
  end
end
