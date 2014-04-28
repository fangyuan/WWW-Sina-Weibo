package WWW::Sina::Weibo::Status;

use Moose::Role;
use Data::Dumper;
use feature qw/say/;

with 'WWW::Sina::Weibo::Request';

sub mentions {
    my $self   = shift;
    my $params = shift;

    $params                     = {}                  unless $params;
    $params->{access_token}     = $self->access_token unless exists $params->{access_token};
    $params->{since_id}         = 0                   unless exists $params->{since_id};
    $params->{max_id}           = 0                   unless exists $params->{max_id};
    $params->{count}            = 200                 unless exists $params->{count};
    $params->{page}             = 1                   unless exists $params->{page};
    $params->{filter_by_author} = 0                   unless exists $params->{filter_by_author};
    $params->{filter_by_source} = 0                   unless exists $params->{filter_by_source};

    my $base_url = 'https://api.weibo.com/2/statuses/mentions.json';
    my $url      = $self->url( $base_url, $params );
    my $data     = $self->get($url);

    return $data;
}

sub mentions_batch {
    my $self   = shift;
    my $params = shift;

    $params = {} unless $params;
    my @mentions = ();
    while (1) {
        my $data = $self->mentions($params);
        last unless $data;
        push @mentions, @{ $data->{statuses} };
        my $current_page = exists $params->{page} ? $params->{page} : 1;
        last if $current_page > 3;
        last unless $data->{total_number} > $current_page * $params->{count};
        $params->{page}++;
    }

    return \@mentions;
}

sub show {
    my $self   = shift;
    my $params = shift;

    $params = { id => $params } unless ref $params;
    return unless exists $params->{id} and $params->{id} and $params->{id} =~ /^\d+$/;

    $params->{access_token} = $self->access_token unless exists $params->{access_token};

    my $base_url = "https://api.weibo.com/2/statuses/show.json";
    my $url      = $self->url( $base_url, $params );
    my $data     = $self->get($url);
    return $data;
}

sub show_batch {
    my $self   = shift;
    my $params = shift;

    return unless exists $params->{ids} and $params->{ids} and ref $params->{ids};

    $params->{access_token} = $self->access_token unless exists $params->{access_token};
    $params->{source}       = $self->appkey       unless exists $params->{source};

    my @statuses;
    my $base_url = "https://api.weibo.com/2/statuses/show_batch.json";
    my @mids     = @{ $params->{ids} };
    my $total    = scalar(@mids);
    my $max      = 50;
    my $start    = 0;
    for ( my $start = 0; $start < $total; $start += $max ) {
        my $end = ( $start + 50 ) < $total ? ( $start + $max - 1 ) : ( $total - 1 );
        my @ids = @mids[$start .. $end];
        $params->{ids} = join( ",", @ids );
        my $url = $self->url( $base_url, $params );
        my $data = $self->get($url);
        push @statuses, @{ $data->{statuses} } if exists $data->{statuses};
    }
    return \@statuses if scalar(@statuses);
}

1;
