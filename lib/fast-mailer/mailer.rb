module FastMailer
  class Mailer
    
    def initialize(options = nil)
      @options = options
    end
    
    def send_all(mail_generator)
      @mail_generator = mail_generator
      @mutex = Mutex.new

      tcount = (@options && @options[:max_connections]) || 1
      threads = []
      
      if tcount > 1
        tcount.times do |n|
          threads << Thread.new(n) do |tid|
            send_until_done
          end
        end
      
        threads.each { |thr| thr.join }
      else
        send_until_done
      end
    end
    

    private
    def send_until_done
      smtp = FastMailer::SMTP.new @options
      while (true)
        begin
          peek_mail
          smtp.open do
            while true
              smtp.deliver next_mail
            end
          end
        rescue StandardError => e
          raise e if StopIteration === e
          sleep 2 unless FastMailer.test_mode
        end
      end
    rescue StopIteration
      # Expected.
    end
    
    def next_mail
      @mutex.synchronize do
        @mail_generator.next
      end
    end
    
    def peek_mail
      @mutex.synchronize do
        @mail_generator.peek
      end
    end
    
  end
end
