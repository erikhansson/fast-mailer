
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
  end
end
