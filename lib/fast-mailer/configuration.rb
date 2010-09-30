# encoding: utf-8

module FastMailer
  class Configuration
    
    def self.smtp_configuration(options = nil)
      if options.is_a? Hash
        options
      else
        eval(File.read(options || File.expand_path("~/.config/smtp.rb")))
      end
    end
    
  end
end
