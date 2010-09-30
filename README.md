FastMailer
==========

FastMailer is a collection of helpers that aims to help with sending email.
Specifically, it allows for convenient configuration and better throughput
when sending multiple mails using SMTP.


Configuration
-------------

The FastMailer senders are configured with a regular options hash, pretty 
much what you'd expect:

    FastMailer::SMTP.new({
      :host => 'mail.authsmtp.com',
      :port => 2525,
      :authentication => :cram_md5,
      :domain => 'mydomain.com',
      :username => 'username',
      :password  => 'password'
    })

Something I've found very convenient, however, is to let the gem read the
default configuration from your home directory. For instance, let's assume
we put:

    {
      :host => 'mail.authsmtp.com',
      :port => 2525,
      :authentication => :cram_md5,
      :domain => 'mydomain.com',
      :username => 'username',
      :password  => 'password'
    }
    
into **~/.config/smtp.rb**, you could then achieve the same result by simply
not providing any options at all. This makes it really easy to write small 
scripts that send email without having to worry about configuration.


Sending mail
------------

When sending a lot of mail, every second counts - especially if you don't
have your SMTP server close by. To reduce the time it takes to send a lot of
email, we can send multiple emails using a single connection.

    mail = build_mail_somehow # mail is a Mail instance (as from the mail gem)
    
    FastMailer::SMTP.new.open do |smtp|
      smtp.deliver mail
      mail.to = 'another@recipient.com'
      smtp.deliver mail
    end


Testing
-------

To enable testing, first run

    FastMailer.test_mode = true

This will cause FastMailer::SMTP to use FastMailer::MockSMTP rather than Net::SMTP. 
You can then find your sent emails in FastMailer::MockSMTP.deliveries.


Coming features
---------------

* Parallelisation: given a list of mails, or a mail generator, we can spin a number
of threads up and let them send mail simultaneously. As most of the time is spent
waiting for the network, this speeds the process up significantly.

* Logging: When sending large batches, sometimes things go wrong. If we keep track 
of which mails have been sent and which have failed, we reduce the risk of finding
ourselves wondering which of our users have received the message and which we need
to send to.

* Blacklisting: block addresses so they cannot be sent to.
