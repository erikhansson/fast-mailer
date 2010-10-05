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


Parallelisation
---------------

To send a large number of emails, you can use the FastMailer::Mailer class. Create
it as an SMTP instance, but include an additional option :max_connections. When 
calling send_all with a mail iterator (any object yielding Mail instances on :next), 
:max_connections threads will be spawned, sending mail from the generator in parallel.

    emails = [mail_1, mail_2, ..., mail_n]
    mailer = FastMailer::Mailer.new
    mailer.send_all emails.to_enum

Note that the generator must not return modified instances of the same object 
multiple times, since up to :max_connections mails will be processed at the same
time.

The :send_all call will not return until all mails have been sent. At this point, all
spawned threads will have stopped.


Coming features
---------------

* Logging: Maybe add a convenient default logging component that will save a brief
description of the sent mails (subject and all recipients, perhaps). The callbacks
should be sufficient to handle the more general purpose requirements. I think.

* Command-line utility: Add a command line utility that enables you to easily send
email, both for testing purposes, and to get the finished emails out to large number
of people. Depending on how many features this would need, maybe this should be a
separate project?
