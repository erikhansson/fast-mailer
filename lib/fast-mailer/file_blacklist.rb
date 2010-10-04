
module FastMailer
  
  # Simplistic blacklist implementation. Reads a text file with a single
  # email address per line into memory. Addresses found are considered
  # blacklisted.
  class FileBlacklist
    
    def initialize(filename)
      @blacklist = []
      
      File.open(filename, 'r:utf-8') do |file|
        while line = file.gets
          @blacklist << line.strip
        end
      end
    end
    
    def blacklisted?(email)
      @blacklist.include?(email)
    end
    
  end
end
