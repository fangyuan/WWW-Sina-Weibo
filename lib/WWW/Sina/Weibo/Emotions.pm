package WWW::Sina::Weibo::Emotions;

use Moose::Role;
use Data::Dumper;
use feature qw/say/;

with 'WWW::Sina::Weibo::Request';

sub emotions {
    my $self   = shift;
    my $params = shift;

    $params = {} unless $params;
    $params->{access_token} = $self->access_token unless exists $params->{access_token};

    my $base_url = 'https://api.weibo.com/2/emotions.json';
    my $url      = $self->url( $base_url, $params );
    my $data     = $self->get($url);

    return $data;
}

sub emotions_batch {
    my $self   = shift;
    my $params = shift;

    $params = {} unless $params;
    my @emotions = ();
    my $types    = $params->{types};
    $types = ['face', 'ani', 'cartoon'] unless $types and ref $types;
    delete $params->{types};
    foreach my $type (@$types) {
        $params->{type} = $type;
        my $data = $self->emotions($params);
        push @emotions, @$data;
    }

    return \@emotions;
}

1;
