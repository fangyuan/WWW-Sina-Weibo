package WWW::Sina::Weibo::ShortURL;

use Moose::Role;
use DateTime;
use JSON::XS qw/decode_json/;
use URI::Escape;
use Data::Dumper;

with 'WWW::Sina::Weibo::Request';

sub url_shorten {
    my $self     = shift;
    my $url_long = $self->_parse_url(@_);
    return unless $url_long;
    my @url_long = map { "url_long=" . $_; } @$url_long;

    my $api_url = 'https://api.weibo.com/2/short_url/shorten.json';
    my $url     = $api_url . '?access_token=' . $self->access_token . '&' . join( '&', @url_long );
    my $data    = $self->get($url);
    return $data->{urls} if $data;
}

sub url_expand {
    my $self      = shift;
    my $url_short = $self->_parse_url(@_);
    return unless $url_short;

    my @url_short = map { "url_short=" . $_; } @$url_short;
    my $api_url   = 'https://api.weibo.com/2/short_url/expand.json';
    my $url       = $api_url . '?access_token=' . $self->access_token . '&' . join( '&', @url_short );
    my $data      = $self->get($url);
    return $data->{urls} if $data;
}

sub url_expand_batch {
    my $self = shift;
    my $urls = shift;

    return unless $urls and ref $urls;

    my %urls;
    if ( ref $urls eq 'ARRAY' ) {
        map { $urls{$_} = 0; } @$urls;
    }
    elsif ( ref $urls eq 'HASH' ) {
        map { $urls{$_} = 0; } keys %$urls;
    }

    my @urls = keys %urls;
    return unless scalar(@urls);

    my $batch_max = 20;
    my $start     = 0;
    my $end       = 0;
    while ( $start < scalar(@urls) ) {
        $end = scalar(@urls) < ( $start + $batch_max -1 ) ? scalar(@urls) - 1 : $start + $batch_max - 1;
        my @url_short = @urls[$start .. $end];
        my $data      = $self->url_expand( \@url_short );
        last unless $data;
        map {
            my $url = $_;
            $urls{ $url->{url_short} } = $url->{url_long};
        } @$data;
        $start += $batch_max;
    }

    return \%urls;
}

sub url_share_status {
    my $self   = shift;
    my $params = shift;

    return unless exists $params->{url_short};

    $params->{url_short} = uri_escape( $params->{url_short} );
    $params->{access_token} = $self->access_token unless exists $params->{access_token};
    my $url = 'https://api.weibo.com/2/short_url/share/statuses.json?' . join( '&', map { $_ . '=' . $params->{$_}; } keys %$params );
    my $data = $self->get($url);
    return $data;
}

sub _parse_url {
    my $self = shift;
    my @url;
    if ( scalar(@_) == 1 ) {
        my $args = shift;
        if ( ref $args ) {
            if ( ref $args eq 'ARRAY' ) {
                @url = @$args;
            }
        }
        else {
            push @url, $args;
        }
    }
    else {
        @url = @_;
    }
    return \@url if scalar(@url);
}

1;
