package WWW::Sina::Weibo;

use strict;
use warnings;
use utf8;
use Moose;
use DateTime;
use Mojo::UserAgent;
use Data::Dumper;

our $VERSION = '0.01';

with 'WWW::Sina::Weibo::OAuth', 'WWW::Sina::Weibo::ShortURL', 'WWW::Sina::Weibo::Status', 'WWW::Sina::Weibo::Emotions';

has appkey           => ( is => 'ro', isa => 'Str',             required => 1 );
has appsecret        => ( is => 'ro', isa => 'Str',             required => 1 );
has authorize_uri    => ( is => 'ro', isa => 'Str',             default  => '' );
has access_token_uri => ( is => 'ro', isa => 'Str',             default  => '' );
has redirect_uri     => ( is => 'ro', isa => 'Str',             default  => '' );
has access_token     => ( is => 'rw', isa => 'Str',             default  => '' );
has ua               => ( is => 'ro', isa => 'Mojo::UserAgent', lazy     => 1, default => sub { Mojo::UserAgent->new } );

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    if ( @_ == 0 ) {
        my $config = {};
        return $class->$orig(
            appkey           => $config->{appkey},
            appsecret        => $config->{appsecret},
            authorize_uri    => $config->{authorize_uri},
            access_token_uri => $config->{access_token_uri},
            redirect_uri     => $config->{auth_redirect_uri},
        );
    }
    else {
        return $class->$orig(@_);
    }
};

1;

=head1 NAME

WWW::Sina::Weibo - Perl extension for blah blah blah

=head1 SYNOPSIS

  use WWW::Sina::Weibo;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for WWW::Sina::Weibo, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

fangyuan, E<lt>Apple@localE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by fangyuan

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
