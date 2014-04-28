package WWW::Sina::Weibo::OAuth;

use Moose::Role;
use DateTime;
use JSON::XS qw/decode_json/;

sub get_access_token {
    my $self           = shift;
    my $authorize_code = shift;

    return unless $authorize_code;

    my $grant_type = 'authorization_code';
    my $params     = {
        client_id     => $self->appkey,
        client_secret => $self->appsecret,
        grant_type    => $grant_type,
        code          => $authorize_code,
        redirect_uri  => $self->redirect_uri,
    };
    my $response = $self->ua->post( $self->access_token_uri, $params );
    if ( $response->is_success ) {
        my $data;
        eval { $data = decode_json( $response->content ); };
        if ($data) {
            my $token = $self->create_or_update_token( $data->{access_token}, $data->{expires_in} );
            return 1 if $token;
        }
    }
    return 0;
}

1;
