# encoding: utf-8

module FastMailer
  class Configuration
    
    TEST_CONFIGURATION = {
      :something => :useful
    }
    
    def self.enable_testing!
      def self.smtp_configuration(options = nil)
        TEST_CONFIGURATION
      end
    end
    
    def self.disable_testing!
      def self.smtp_configuration(options = nil)
        if options.is_a? Hash
          options
        else
          eval(File.read(options || File.expand_path("~/.config/smtp.rb")))
        end
      end
    end
    
    disable_testing!
    
  end
end
