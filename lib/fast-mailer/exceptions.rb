
module FastMailer
  class FastMailerError < ArgumentError
  end
  
  class BlacklistError < FastMailerError
  end
end
