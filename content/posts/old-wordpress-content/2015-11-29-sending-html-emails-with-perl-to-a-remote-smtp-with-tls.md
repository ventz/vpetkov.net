---
title: Sending HTML emails with Perl to a remote SMTP with TLS
author: Ventz
type: posts
date: 2015-11-30T04:38:35+00:00
url: /2015/11/29/sending-html-emails-with-perl-to-a-remote-smtp-with-tls/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - mutt
  - perl
  - postfix
  - smtp

---
This problem starter as a rather simple one - I needed to send HTML emails, using Perl, to a remote SMTP server with user authentication and TLS support (STARTTLS). The extra "gotcha" is that I refused to read books about MIME structures. Easy enough right? It turns out, it can be if you know the right answer.

Let start with the answer for those that are impatient - it turns out this is the easiest way to achieve this:  
```perl
sub amazon_sendhtmlemail_to_from {
    my ($from_email, $to_email, $subject, $url) = @_;
    # Pull HTML content down from URL
    use WWW::Mechanize;
    my $mech = WWW::Mechanize->new();
    $mech->agent_alias( 'Mac Safari' );
    $mech->get( $url );
    my $html = $mech->content;
    # Create Email itself - hard part, in HTML use Email::Stuffer;
    # The "->email" is key because it returns a Email::MIME object which is needed for the send
    my $email = Email::Stuffer->from($from_email)->to($to_email)->subject($subject)->html_body($html)->email;
    ###############################################################################
    use Email::Sender::Simple qw(sendmail);
    use Email::Sender::Transport::SMTPS ();
    my $smtpserver = 'smtp.domain.tld';
    my $smtpport = 587;
    my $smtpuser   = 'Username';
    my $smtppassword = 'Password';
    my $transport = Email::Sender::Transport::SMTPS->new({
        host => $smtpserver,
        port => $smtpport,
        ssl => "starttls",
        sasl_username => $smtpuser,
        sasl_password => $smtppassword,
    });
    sendmail($email, { transport => $transport });
    ###############################################################################
}
```

That's it - and "it just works" (TM). As you might have guessed, this is also the perfect solution for something like Amazon's AWS SES service.

<!--more-->

I usually send emails with MIME::Lite. It's a beautifully simple module that "just works". Typically, someting like this for plain/non-html emails:  
```perl
sub sendemail_to_from {
    my ($from_email, $to_email, $subject, $body) = @_;
    my $msg = MIME::Lite->new(
        From     =>"$from_email",
        To       =>"$to_email",
        Subject  =>"$subject",
        Data     =>"$body"
    );
    $msg->send;
}
```

But this doesn't send HTML. Ok, easy enough - there is a module called MIME::Lite::HTML. Something like this should work:  
```perl
sub sendhtmlemail_to_from {
    my ($from_email, $to_email, $subject, $url) = @_;
    my $msg = MIME::Lite::HTML->new(
        From     =>"$from_email",
        To       =>"$to_email",
        Subject  =>"$subject",
        Url      =>"$url",
        IncludeType =>'extern',
    );
}
```

The gotcha here is that the email "body" is composed from an URL, and the email is fired off immediately after retrieving the "$url" parameter. I've added an extra "IncludeType" of "extern" which means that I want the images not to be embeeded, but instead to be fetched remotely as the user reads the email.

Great. Simple and beautiful again. But what if you want to send this through a remote SMTP server?  
Ok, so it's a bit of a hack between MIME::Lite and MIME::HTML::Lite, but it's again pretty easy. Something like this:  
```perl
sub sendhtmlemail_via_remote_smtp_to_from {
    my ($from_email, $to_email, $subject, $url) = @_;
    my $msg = MIME::Lite::HTML->new(
        From     =>"$from_email",
        To       =>"$to_email",
        Subject  =>"$subject",
        IncludeType =>'extern',
    );
    # This takes the MIME::Lite::HTML object, and manually "parses" the URL.
    # The result is actually a MIME::Lite object on which you can execute "send"
    my $m = $msg->parse($url);
    # NOTE: If you are using v3.0+, you can actually include "SSL => 1"
    $m->send('smtp', $smtp_host, AuthUser=>$user, AuthPass=>$pass );
}
```

This is again kind of interesting. Simple enough, and it uses/abuses the fact that you could potentially be on a "windows" system (per the developer's example :)) and not have sendmail. This way, you are creating a MIME::Lite::HTML object, and then manually retrieving the URL which ends up creating a MIME::Lite object with the MIME::Lite::HTML data. Then you can manually execute "send" and specify a SMTP host, an username and a password. Not bad.

But what if you need SSL/TLS? (Those pesky need STARTTLS requests? - that most servers out there need)  
Well, if you are using v3.0 of NET::SMTP, you could pass in "SSL => 1". Supposedly that should do it. I have not been able to verify that.

The alternative is writing a handler yourself:  
```perl
sub sendhtmlemail_via_remote_smtp_to_from {
    my ($from_email, $to_email, $subject, $url) = @_;
    my $msg = MIME::Lite::HTML->new(
        From     =>"$from_email",
        To       =>"$to_email",
        Subject  =>"$subject",
        IncludeType =>'extern',
    );
    # This takes the MIME::Lite::HTML object, and manually "parses" the URL.
    # The result is actually a MIME::Lite object on which you can execute "send"
    my $m = $msg->parse($url);
    my $smtpserver = 'smtp.domain.tld';
    my $smtpport = 587;
    my $smtpuser   = 'Username';
    my $smtppassword = 'Password';
    my $mailer = new Net::SMTP::TLS(
        "$smtpserver",
        Hello   =>      'smtp.host.tld',
        Port    =>      $smtpport,
        User    =>      $smtpuser,
        Password=>      $smtppassword);
    $mailer->mail("$from_email");
    $mailer->to("$to_email");
    $mailer->data;
    # This is the key part why you need a MIME::Lite object and NOT a MIME::Lite::HTML
    $mailer->datasend($m->as_string);
    $mailer->dataend;
    $mailer->quit;
}
```

This works "well" for non-html stuff. For HTML stuff it produces mixed results. If you relay it via something like postfix, it mostly works. If you relay it via something like Amazon's AWS SES service - it ends up breaking the HTML. Again, the problem is how do you do this in a simple/elegant way?

There are many solutions out there. What I noticed is that most used complicated headers/additional pieces of info. This really bothered me since I didn't want to deal with any of this. Ideally, I wanted an "add-on" to MIME::Lite::HTML which simply did authentication and TLS. This would have been the perfect solution. Sadly, this does not exist. Until it does, the easiest way achieve this is with the first solution I posted - using Email::Stuffer (which is an abstraction to a complicated MIME::Email) and Email::Sender** (Simple and Transport::SMTPS) to create your own secure and authenticated SMTP transport.

I hope this saves someone some time, because this simple stupid problem ended up wasting quite a bit of my time.
